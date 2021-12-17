// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IClaimConfig {
    function getClaimAmount(address who_) external view returns(uint256);
    function getClaimDuration(address who_) external view returns(uint256);
}
