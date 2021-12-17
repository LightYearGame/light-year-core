// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IUpgradeableConfig {
    function maximumLevel(uint256 itemIndex_) external view returns(uint256);
    function getTokenArray(uint256 itemIndex_, uint256 level_) external view returns(address[] memory);
    function getCostArray(uint256 itemIndex_, uint256 level_) external view returns(uint256[] memory);
}
