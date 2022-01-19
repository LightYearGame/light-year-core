// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "../interface/IRegistry.sol";
import "../interface/IShip.sol";
import "../interface/IShipConfig.sol";
import "../interface/ICommodityERC20.sol";

import "../common/PreMintable.sol";
import "../common/OnlyEOA.sol";

contract Ship is ERC721, IShip, PreMintable, OnlyEOA {

    string constant public TOKEN_NAME = "LightYearShip";
    string constant public TOKEN_SYMBOL = "LYS";
    string constant public TOKEN_BASE_URI = "https://lightyear.game/ship/";

    // Token id to ship info
    mapping(uint256 => Info) private _shipInfoMap;

    // Registry
    address public registryAddress;

    // Next token id.
    uint256 public nextTokenId = 1;

    event BuildShip(address who_, uint256 shipType_);
    event UpgradeShip(address who_, uint256 fromTokenId_, uint256 toTokenId_, uint8 level_);

    /**
     * constructor
     */
    constructor(address registry_) public ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
        registryAddress = registry_;
        _setBaseURI(TOKEN_BASE_URI);
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function shipConfig() private view returns (IShipConfig){
        return IShipConfig(registry().shipConfig());
    }

    function shipInfo(uint256 shipId_) public override view returns (Info memory){
        return _shipInfoMap[shipId_];
    }

    // Only for premint. Check PreMintable.sol
    function mint(address to_, uint8[] memory shipTypeArray_) external onlyForPreMint {
        for (uint256 i = 0; i < shipTypeArray_.length; ++i) {
            _mintShip(to_, shipTypeArray_[i]);
        }
    }

    function buildShip(uint8 shipType_) external override onlyEOA {
        address[] memory tokenArray = shipConfig().getBuildTokenArray(shipType_);
        uint256[] memory costs = shipConfig().getBuildShipCost(shipType_);
        require(tokenArray.length == costs.length, "buildShip: require same array length.");

        for (uint256 i = 0; i < tokenArray.length; i++) {
            ICommodityERC20(tokenArray[i]).transferFrom(_msgSender(), address(this), costs[i]);
            ICommodityERC20(tokenArray[i]).burn(costs[i]);
        }

        _mintShip(_msgSender(), shipType_);

        emit BuildShip(_msgSender(), shipType_);
    }

    /**
     * Mint ship
     */
    function _mintShip(address addr_, uint8 shipType_) private {
        // Mint nft
        uint256 tokenId = nextTokenId;
        ++nextTokenId;

        _mint(addr_, tokenId);

        // Create ship info
        _shipInfoMap[tokenId] = Info({
            level: 1,
            quality: _randomShipQuality(totalSupply()),
            shipType: shipType_
        });
    }

    function _randomShipQuality(uint256 seed_) private view returns (uint8) {
        return shipConfig().randomShipQuality(seed_);
    }

    /**
     * Upgrade ship.
     */
    function upgradeShip(uint256 fromTokenId_, uint256 toTokenId_) external override {
        require(fromTokenId_ != toTokenId_, "upgradeShip: require different ship.");
        require(ownerOf(fromTokenId_) == _msgSender(), "upgradeShip: require owner.");
        require(ownerOf(toTokenId_) == _msgSender(), "upgradeShip: require owner.");

        Info memory shipFrom = _shipInfoMap[fromTokenId_];
        Info storage shipTo = _shipInfoMap[toTokenId_];

        require(shipFrom.shipType == shipTo.shipType, "upgradeShip: require same ship type.");
        require(shipFrom.level == shipTo.level, "upgradeShip: require same ship level.");

        shipTo.quality = shipFrom.quality > shipTo.quality ? shipFrom.quality : shipTo.quality;
        ++shipTo.level;

        // Burn ship
        _burn(fromTokenId_);
        delete _shipInfoMap[fromTokenId_];

        emit UpgradeShip(_msgSender(), fromTokenId_, toTokenId_, shipTo.level);
    }
}
