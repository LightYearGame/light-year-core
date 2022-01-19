// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../interface/IFarm.sol";

interface IMasterChef {
    function pendingCake(uint256 pid_, address user_) external view returns(uint256);
    function deposit(uint256 pid_, uint256 amount_) external;
    function withdraw(uint256 pid_, uint256 amount_) external;
    function claim(uint256 pid_) external;
}


contract PancakeFarm is IFarm {

    using SafeERC20 for IERC20;

    address public staking;
    IMasterChef public chef;
    IERC20 public cake;

    // chef_
    // https://bscscan.com/address/0x73feaa1ee314f8c655e354234017be2193c9e24e#code
    constructor (address staking_, IMasterChef chef_, IERC20 cake_) public {
        staking = staking_;
        chef = chef_;
        cake = cake_;
    }

    function pendingReward(uint256 pid_) external override view returns(uint256) {
        return chef.pendingCake(pid_, address(this));
    }

    function deposit(address token_, uint256 pid_, uint256 amount_) external override {
        require(msg.sender == staking, "Staking only");

        IERC20(token_).safeTransferFrom(staking, address(this), amount_);

        IERC20(token_).approve(address(chef), amount_);
        chef.deposit(pid_, amount_);

        uint256 cakeBalance = cake.balanceOf(address(this));
        cake.safeTransfer(staking, cakeBalance);
    }

    function withdraw(address token_, uint256 pid_, uint256 amount_) external override {
        require(msg.sender == staking, "Staking only");

        chef.withdraw(pid_, amount_);
        IERC20(token_).safeTransfer(staking, amount_);
        uint256 cakeBalance = cake.balanceOf(address(this));
        cake.safeTransfer(staking, cakeBalance);
    }

    function claim(uint256 pid_) external override {
        require(msg.sender == staking, "Staking only");

        chef.deposit(pid_, 0);
        uint256 cakeBalance = cake.balanceOf(address(this));
        cake.safeTransfer(staking, cakeBalance);
    }
}
