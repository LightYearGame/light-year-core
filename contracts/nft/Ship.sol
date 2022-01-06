// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "../interface/IRegistry.sol";
import "../interface/IShip.sol";
import "../interface/IShipConfig.sol";
import "../interface/ICommodityERC20.sol";

contract Ship is ERC721, IShip {

    string constant public TOKEN_NAME = "LightYearShip";
    string constant public TOKEN_SYMBOL = "LYS";
    string constant public TOKEN_BASE_URI = "https://lightyear.game/ship/";

    // Token id to ship
    mapping(uint256 => Info) private _shipInfoMap;

    // Registry
    address public registryAddress;

    // Next token id.
    uint256 public nextTokenId = 1;

    // Only operator
    modifier onlyOperator(){
        require(registry().isOperator(msg.sender), "onlyOperator: require operator.");
        _;
    }

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

    function setBaseURI(string memory baseURI_) external {
        _setBaseURI(baseURI_);
    }

    function operatorTransfer(address from_, address to_, uint256 tokenId_) external override onlyOperator {
        _transfer(from_, to_, tokenId_);
    }

    function shipInfo(uint256 shipId_) public override view returns (Info memory){
        return _shipInfoMap[shipId_];
    }

    function buildShip(uint8 shipType_) public {
        address[] memory tokenArray = shipConfig().getBuildTokenArray(shipType_);
        uint256[] memory costs = shipConfig().getBuildShipCost(shipType_);
        require(tokenArray.length == costs.length, "buildShip: require same array length.");

        for (uint i = 0; i < tokenArray.length; i++) {
            ICommodityERC20(tokenArray[i]).operatorTransfer(_msgSender(), address(this), costs[i]);
            ICommodityERC20(tokenArray[i]).burn(costs[i]);
        }

        _mintShip(_msgSender(), shipType_);
    }

    /**
     * mint ship
     */
    function _mintShip(address addr_, uint8 shipType_) private {

        //mint nft
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
     *
     */
    function upgradeShip(uint256 shipFromTokenId_, uint256 shipToTokenId_) external override {
        require(shipFromTokenId_ != shipToTokenId_, "upgradeShip: require different ship.");
        require(ownerOf(shipFromTokenId_) == _msgSender(), "upgradeShip: require owner.");
        require(ownerOf(shipToTokenId_) == _msgSender(), "upgradeShip: require owner.");

        Info memory shipFrom = _shipInfoMap[shipFromTokenId_];
        Info storage shipTo = _shipInfoMap[shipToTokenId_];

        require(shipFrom.shipType == shipTo.shipType, "upgradeShip: require same ship type.");
        require(shipFrom.level == shipTo.level, "upgradeShip: require same ship level.");

        shipTo.quality = shipFrom.quality > shipTo.quality ? shipFrom.quality : shipTo.quality;
        ++shipTo.level;

        // Burn ship
        _burn(shipFromTokenId_);
        delete _shipInfoMap[shipFromTokenId_];
    }
}
