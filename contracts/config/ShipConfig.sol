// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "../interface/IShipConfig.sol";
import "../interface/IRegistry.sol";
import "../common/Randomness.sol";

contract ShipConfig is IShipConfig, Randomness {

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
        if (shipType_ == 6) {
            array[0] = 100e18;
            array[1] = 0;
        } else if (shipType_ == 8) {
            array[0] = 400e18;
            array[1] = 0;
        } else if (shipType_ == 12) {
            array[0] = 1000e18;
            array[1] = 0;
        } else if (shipType_ == 15) {
            array[0] = 2000e18;
            array[1] = 2000e18;
        } else {
            require(false, "Not implemented");
        }

        return array;
    }

    function getBuildShipCostByLevel(uint8 shipType_, uint8 level_) public pure override returns (uint256[] memory){
        require(level_ >= 1, "invalid ship level.");
        uint256[] memory array = getBuildShipCost(shipType_);
        for (uint i = 0; i < array.length; i++) {
            array[i] = array[i] * 2 ** (level_ - 1);
        }
        return array;
    }

    function randomShipQuality(uint256 seed_) public view override returns (uint8) {
        return uint8(getRandomNumber(seed_) % 100 + 1);
    }
}
