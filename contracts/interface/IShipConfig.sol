// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./IShip.sol";

interface IShipConfig {
    function getBuildTokenArray(uint8 shipType_) external view returns (address[] memory);
    function getBuildShipCost(uint8 shipType_) external pure returns (uint256[] memory);
    function getShipAttackById(uint256 shipId_) external view returns(uint256);
    function getShipAttackByInfo(IShip.Info memory shipInfo_) external view returns(uint256);
    function getRealDamageByInfo(IShip.Info memory attacker_, IShip.Info memory defender_) external view returns(uint256);
    function getAttributesById(uint256 shipId_) external view returns(uint256[] memory);
    function getAttributesByInfo(IShip.Info memory info_) external view returns(uint256[] memory);
    function getShipCategory(uint8 shipType_) external pure returns(uint256);
    function getShipCategoryById(uint256 shipId_) external view returns(uint256);
    function randomShipQuality(uint256 seed_) external view returns (uint8);
}
