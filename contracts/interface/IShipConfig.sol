// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./IShip.sol";

interface IShipConfig {
    function getBuildTokenArray(uint8 shipType_) external view returns (address[] memory);
    function getBuildShipCost(uint8 shipType_) external pure returns (uint256[] memory);
    function getBuildShipCostByLevel(uint8 shipType_, uint8 level_) external pure returns (uint256[] memory);
    function randomShipQuality(uint256 seed_) external view returns (uint8);
}
