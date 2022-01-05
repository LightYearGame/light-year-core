// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IFarm {
    function pendingReward(uint256 pid_) external view returns(uint256);
    function deposit(address token_, uint256 pid_, uint256 amount_) external;
    function withdraw(address token_, uint256 pid_, uint256 amount_) external;
    function claim(uint256 pid_) external;
}
