// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./../interface/IShipConfig.sol";
import "./../interface/IRegistry.sol";
import "./../interface/IShip.sol";

contract ShipConfig is IShipConfig {

    address public registryAddress;

    constructor(address registry_) public {
        registryAddress = registry_;
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function ship() private view returns (IShip){
        return IShip(registry().ship());
    }

    function getBuildTokenArray(uint8 shipType_) public view override returns (address[] memory){
        address[] memory array = new address[](2);
        array[0] = registry().tokenIron();
        array[1] = registry().tokenGold();
        return array;
    }

    function getShipAttackById(uint256 shipId_) public view override returns (uint256){
        IShip.Info memory shipInfo = ship().shipInfo(shipId_);
        return getShipAttackByInfo(shipInfo);
    }

    function getShipAttackByInfo(IShip.Info memory shipInfo_) public view override returns (uint256){
        uint256[] memory attrs = getAttributesByInfo(shipInfo_);
        return attrs[3];
    }

    function getRealDamageByInfo(IShip.Info memory attacker_, IShip.Info memory defender_) public view override returns (uint256){
        uint256[] memory attackerAttrs = getAttributesByInfo(attacker_);
        uint256[] memory defenderAttrs = getAttributesByInfo(defender_);
        uint256 attack = attackerAttrs[3];
        uint256 defense = defenderAttrs[4];
        return attack * attack / (attack + defense);
    }

    function getAttributesById(uint256 shipId_) public view override returns (uint256[] memory){
        IShip.Info memory shipInfo = ship().shipInfo(shipId_);
        return getAttributesByInfo(shipInfo);
    }

    function getAttributesByInfo(IShip.Info memory info_) public view override returns (uint256[] memory){
        uint16 level = info_.level;
        uint16 quality = info_.quality;
        //attrs
        uint256 health = quality * 2;
        uint256 attack = quality + 50;
        uint256 defense = quality + 50;

        uint256[] memory attrs = new uint256[](5);
        attrs[0] = level;
        attrs[1] = quality;
        attrs[2] = health;
        attrs[3] = attack;
        attrs[4] = defense;
        return attrs;
    }

    function getShipCategory(uint8 shipType_) public override pure returns (uint256){
        if (shipType_ == 6 || shipType_ == 8 || shipType_ == 12 || shipType_ == 15) {
            return 0;
        } else if (shipType_ == 1 || shipType_ == 5) {
            return 1;
        } else if (shipType_ == 4 || shipType_ == 11 || shipType_ == 14) {
            return 2;
        } else {
            return 3;
        }
    }

    function getShipCategoryById(uint256 shipId_) public override view returns (uint256){
        IShip.Info memory info = ship().shipInfo(shipId_);
        return getShipCategory(info.shipType);
    }

    function getBuildShipCost(uint8 shipType_) public pure override returns (uint256[] memory){
        uint256[] memory array = new uint256[](2);
        if (shipType_ == 1) {
            array[0] = 100;
            array[1] = 100;
        } else if (shipType_ == 2) {
            array[0] = 100;
            array[1] = 100;
        } else if (shipType_ == 3) {
            array[0] = 300;
            array[1] = 300;
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
            array[0] = 600;
            array[1] = 600;
        } else if (shipType_ == 8) {
            array[0] = 500;
            array[1] = 500;
        } else if (shipType_ == 9) {
            array[0] = 1000;
            array[1] = 1000;
        } else if (shipType_ == 10) {
            array[0] = 2000;
            array[1] = 2000;
        } else if (shipType_ == 11) {
            array[0] = 800;
            array[1] = 800;
        } else if (shipType_ == 12) {
            array[0] = 2000;
            array[1] = 2000;
        } else if (shipType_ == 13) {
            array[0] = 5000;
            array[1] = 5000;
        } else if (shipType_ == 14) {
            array[0] = 3000;
            array[1] = 3000;
        } else if (shipType_ == 15) {
            array[0] = 8000;
            array[1] = 8000;
        } else if (shipType_ == 16) {
            array[0] = 8000;
            array[1] = 8000;
        } else if (shipType_ == 17) {
            array[0] = 12000;
            array[1] = 12000;
        } else if (shipType_ == 18) {
            array[0] = 15000;
            array[1] = 15000;
        } else if (shipType_ == 19) {
            array[0] = 20000;
            array[1] = 20000;
        }

        array[0] = array[0] * 1e18;
        array[1] = array[1] * 1e18;
        return array;
    }
}