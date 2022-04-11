// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interface/IClaimConfig.sol";
import "../interface/IRegistry.sol";
import "../interface/IUpgradeable.sol";

interface ISoftStaking {
    function infoMap(address who_) external view returns(uint256, uint256, uint256);
}

contract ClaimConfig is IClaimConfig {
    using SafeMath for uint256;

    ISoftStaking public softStaking;

    constructor(ISoftStaking softStaking_) public {
        softStaking = softStaking_;
    }

    function getStakingLevel(address who_) public view returns(uint256) {
        (uint256 balance,,) = softStaking.balanceMap(who_);
        if (balance > 1024000e18) {
            return 11;
        } else if (balance >= 512000e18) {
            return 10;
        } else if (balance >= 256000e18) {
            return 9;
        } else if (balance >= 128000e18) {
            return 8;
        } else if (balance >= 64000e18) {
            return 7;
        } else if (balance >= 32000e18) {
            return 6;
        } else if (balance >= 16000e18) {
            return 5;
        } else if (balance >= 8000e18) {
            return 4;
        } else if (balance >= 4000e18) {
            return 3;
        } else if (balance >= 2000e18) {
            return 2;
        } else if (balance >= 1000e18) {
            return 1;
        } else {
            return 0;
        }
    }

    function getClaimAmount(address who_) external override view returns(uint256) {
        uint256 stakingLevel = getStakingLevel(who_);
        if (stakingLevel == 11) {
            return 102400e18;
        } else if (stakingLevel == 10) {
            return 51200e18;
        } else if (stakingLevel == 9) {
            return 25600e18;
        } else if (stakingLevel == 8) {
            return 12800e18;
        } else if (stakingLevel == 7) {
            return 6400e18;
        } else if (stakingLevel == 6) {
            return 3200e18;
        } else if (stakingLevel == 5) {
            return 1600e18;
        } else if (stakingLevel == 4) {
            return 800e18;
        } else if (stakingLevel == 3) {
            return 400e18;
        } else if (stakingLevel == 2) {
            return 200e18;
        } else if (stakingLevel == 1) {
            return 100e18;
        } else {
            return 20e18;
        }
    }

    function getClaimDuration(address who_) external override view returns(uint256) {
        return (12 hours);
    }
}
