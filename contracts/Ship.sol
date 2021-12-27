// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./token/Nft.sol";
import "./interface/IRegistry.sol";
import "./interface/IShip.sol";
import "./interface/IShipConfig.sol";
import "./interface/ICommodityERC20.sol";

contract Ship is Nft, IShip {

    //const
    string constant public TOKEN_NAME = "LightYearShip";
    string constant public TOKEN_SYMBOL = "LYS";
    string constant public TOKEN_BASE_URI = "https://lightyear.game/ship/";

    //token id to ship
    mapping(uint256 => Info) public shipInfoMap;

    //registry
    address public registryAddress;

    //only operator
    modifier onlyOperator(){
        require(registry().isOperator(msg.sender), "onlyOperator: require operator.");
        _;
    }

    /**
     * constructor
     */
    constructor(address registry_) public Nft(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_BASE_URI) {
        registryAddress = registry_;
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
        return shipInfoMap[shipId_];
    }

    function buildShip(uint8 shipType_) public {
        address[] memory tokenArray = shipConfig().getBuildTokenArray(shipType_);
        uint256[] memory costs = shipConfig().getBuildShipCost(shipType_);
        
        for(uint i=0; i<tokenArray.length; i++){
            ICommodityERC20(tokenArray[i]).burn(costs[i]);
        }

        _mintShip(_msgSender(), shipType_);
    }

    /**
     * mint ship
     */
    function _mintShip(address addr_, uint8 shipType_) private {

        //mint nft
        uint256 tokenId = _mintNft(addr_);

        //create ship
        Info memory info = _createShip(shipType_);
        shipInfoMap[tokenId] = info;
    }

    /**
     * 
     */
    function _burnShip(uint256 tokenId) private {

        //burn nft
        _burnNft(tokenId);

        //burn ship
        delete shipInfoMap[tokenId];
    }

    /**
     *
     */
    function upgradeShip(uint256 shipFromTokenId_, uint256 shipToTokenId_) external override {
        require(shipFromTokenId_ != shipToTokenId_, "upgradeShip: require different ship.");
        require(shipOwnerOf(shipFromTokenId_) == _msgSender(), "upgradeShip: require owner.");
        require(shipOwnerOf(shipToTokenId_) == _msgSender(), "upgradeShip: require owner.");

        Info memory shipFrom = shipInfoMap[shipFromTokenId_];
        Info memory shipTo = shipInfoMap[shipToTokenId_];
        require(shipFrom.shipType == shipTo.shipType, "upgradeShip: require same ship type.");
        require(shipFrom.level == shipTo.level, "upgradeShip: require same ship level.");

        Info memory newShip = Info(shipTo.health, shipTo.quality, shipTo.level + 1, shipTo.shipType);
        shipInfoMap[shipToTokenId_] = newShip;

        //burn ship
        _burnShip(shipFromTokenId_);
    }

    /**
     *
     */
    function _createShip(uint8 shipType) private view returns (Info memory){
        uint16 quality = uint16(_random(100) + 1);
        uint16 level = 1;
        Info memory info = Info(quality + 100, quality, level, shipType);
        return info;
    }

    /**
     * random
     */
    function _random(uint256 randomSize_) private view returns (uint256){
        uint256 nonce = totalSupply();
        uint256 difficulty = block.difficulty;
        uint256 gaslimit = block.gaslimit;
        uint256 number = block.number;
        uint256 timestamp = block.timestamp;
        uint256 gasprice = tx.gasprice;
        uint256 random = uint256(keccak256(abi.encodePacked(nonce, difficulty, gaslimit, number, timestamp, gasprice))) % randomSize_;
        return random;
    }

}