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
        if (shipType_ == 1) {
            require(false, "Not implemented");
        } else if (shipType_ == 2) {
            array[0] = 4000e18;
            array[1] = 4000e18;
        } else if (shipType_ == 3) {
            array[0] = 5000e18;
            array[1] = 5000e18;
        } else if (shipType_ == 4) {
            require(false, "Not implemented");
        } else if (shipType_ == 5) {
            require(false, "Not implemented");
        } else if (shipType_ == 6) {
            array[0] = 100e18;
            array[1] = 0;
        } else if (shipType_ == 7) {
            array[0] = 6000e18;
            array[1] = 6000e18;
        } else if (shipType_ == 8) {
            array[0] = 400e18;
            array[1] = 0;
        } else if (shipType_ == 9) {
            array[0] = 10000e18;
            array[1] = 10000e18;
        } else if (shipType_ == 10) {
            array[0] = 11000e18;
            array[1] = 11000e18;
        } else if (shipType_ == 11) {
            require(false, "Not implemented");
        } else if (shipType_ == 12) {
            array[0] = 1000e18;
            array[1] = 0;
        } else if (shipType_ == 13) {
            array[0] = 12000e18;
            array[1] = 12000e18;
        } else if (shipType_ == 14) {
            require(false, "Not implemented");
        } else if (shipType_ == 15) {
            array[0] = 2000e18;
            array[1] = 2000e18;
        } else if (shipType_ == 16) {
            array[0] = 20000e18;
            array[1] = 20000e18;
        } else if (shipType_ == 17) {
            array[0] = 24000e18;
            array[1] = 24000e18;
        } else if (shipType_ == 18) {
            array[0] = 30000e18;
            array[1] = 30000e18;
        } else if (shipType_ == 19) {
            array[0] = 100000e18;
            array[1] = 100000e18;
        }

        return array;
    }

    function randomShipQuality(uint256 seed_) public view override returns (uint8) {
        return uint8(getRandomNumber(seed_) % 100 + 1);
    }
}
