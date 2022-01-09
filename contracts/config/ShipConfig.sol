// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./../interface/IShipConfig.sol";
import "./../interface/IRegistry.sol";

contract ShipConfig is IShipConfig {

    address public registryAddress;

    constructor(address registry_) public {
        registryAddress = registry_;
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function getBuildTokenArray(uint8 shipType_) public view override returns (address[] memory){
        require(shipType_ >= 1 && shipType_ <= 19, "require correct ship type.");
        address[] memory array = new address[](2);
        array[0] = registry().tokenIron();
        array[1] = registry().tokenGold();
        return array;
    }

    function getBuildShipCost(uint8 shipType_) public pure override returns (uint256[] memory){
        require(shipType_ >= 1 && shipType_ <= 19, "require correct ship type.");
        uint256[] memory array = new uint256[](2);
        if (shipType_ == 1) {
            array[0] = 100;
            array[1] = 100;
        } else if (shipType_ == 2) {
            array[0] = 4000;
            array[1] = 4000;
        } else if (shipType_ == 3) {
            array[0] = 5000;
            array[1] = 5000;
        } else if (shipType_ == 4) {
            array[0] = 100;
            array[1] = 100;
        } else if (shipType_ == 5) {
            array[0] = 1000;
            array[1] = 1000;
        } else if (shipType_ == 6) {
            array[0] = 100;
            array[1] = 100;
        } else if (shipType_ == 7) {
            array[0] = 6000;
            array[1] = 6000;
        } else if (shipType_ == 8) {
            array[0] = 400;
            array[1] = 400;
        } else if (shipType_ == 9) {
            array[0] = 10000;
            array[1] = 10000;
        } else if (shipType_ == 10) {
            array[0] = 11000;
            array[1] = 11000;
        } else if (shipType_ == 11) {
            array[0] = 800;
            array[1] = 800;
        } else if (shipType_ == 12) {
            array[0] = 1000;
            array[1] = 1000;
        } else if (shipType_ == 13) {
            array[0] = 12000;
            array[1] = 12000;
        } else if (shipType_ == 14) {
            array[0] = 3000;
            array[1] = 3000;
        } else if (shipType_ == 15) {
            array[0] = 2000;
            array[1] = 2000;
        } else if (shipType_ == 16) {
            array[0] = 20000;
            array[1] = 20000;
        } else if (shipType_ == 17) {
            array[0] = 24000;
            array[1] = 24000;
        } else if (shipType_ == 18) {
            array[0] = 30000;
            array[1] = 30000;
        } else if (shipType_ == 19) {
            array[0] = 100000;
            array[1] = 100000;
        }
        array[0] = array[0] * 1e18;
        array[1] = array[1] * 1e18;
        return array;
    }

    function randomShipQuality(uint256 seed_) public view override returns (uint8) {
        return uint8(_random(seed_, 100) + 1);
    }

    /**
     * random
     */
    function _random(uint256 seed_, uint256 randomSize_) private view returns (uint256){
        uint256 nonce = seed_;
        uint256 difficulty = block.difficulty;
        uint256 gaslimit = block.gaslimit;
        uint256 number = block.number;
        uint256 timestamp = block.timestamp;
        uint256 gasprice = tx.gasprice;
        uint256 random = uint256(keccak256(abi.encodePacked(nonce, difficulty, gaslimit, number, timestamp, gasprice))) % randomSize_;
        return random;
    }
}
