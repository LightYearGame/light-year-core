// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IMiningConfig {
    function getMultiplier(address who_, uint256 index_) external view returns(uint256);
}
