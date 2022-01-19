// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../interface/IFarm.sol";

interface ITranchessStakingV2 {
    function claimableRewards(address account_) external view returns (uint256);
    function deposit(uint256 tranche_, uint256 amount_) external;
    function withdraw(uint256 tranche_, uint256 amount_) external;
    function claimRewards(address account_) external;
}

// NOTE: Deploy an instance of TranchessFarm for every pid / tranche.
contract TranchessFarm is IFarm {

    using SafeERC20 for IERC20;

    address public staking;
    ITranchessStakingV2 public tranchessStaking;
    IERC20 public chess;

    // tranchessStaking_
    // https://bscscan.com/address/0x42867df3c1ce62613aae3f4238cbcf3d7630880b#code
    constructor (address staking_, ITranchessStakingV2 tranchessStaking_, IERC20 chess_) public {
        staking = staking_;
        tranchessStaking = tranchessStaking_;
        chess = chess_;
    }

    function pendingReward(uint256 pid_) external override view returns(uint256) {
        return tranchessStaking.claimableRewards(address(this));
    }

    function deposit(address token_, uint256 pid_, uint256 amount_) external override {
        require(msg.sender == staking, "Staking only");

        IERC20(token_).safeTransferFrom(staking, address(this), amount_);

        IERC20(token_).approve(address(tranchessStaking), amount_);
        tranchessStaking.deposit(pid_, amount_);

        uint256 chessBalance = chess.balanceOf(address(this));
        chess.safeTransfer(staking, chessBalance);
    }

    function withdraw(address token_, uint256 pid_, uint256 amount_) external override {
        require(msg.sender == staking, "Staking only");

        tranchessStaking.withdraw(pid_, amount_);
        IERC20(token_).safeTransfer(staking, amount_);
        uint256 chessBalance = chess.balanceOf(address(this));
        chess.safeTransfer(staking, chessBalance);
    }

    function claim(uint256 pid_) external override {
        require(msg.sender == staking, "Staking only");

        tranchessStaking.claimRewards(address(this));
        uint256 chessBalance = chess.balanceOf(address(this));
        chess.safeTransfer(staking, chessBalance);
    }
}
