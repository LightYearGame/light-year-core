// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "./interface/IClaimConfig.sol";
import "./interface/ICommodityERC20.sol";
import "./interface/IFarm.sol";
import "./interface/IMiningConfig.sol";
import "./interface/IRegistry.sol";

import "./common/NoReentry.sol";
import "./common/OnlyEOA.sol";

contract Staking is Ownable, NoReentry, OnlyEOA {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 constant UNIT_PER_SHARE = 1e12;
    uint256 constant RATE_BASE = 1e6;
    uint256 constant MULTIPLIER_BASE = 1e6;

    IRegistry public registry;

    struct PoolInfo {
        IFarm farm;
        uint256 farmPid;
        address token;
        address rewardToken;
        uint256 amount;
        uint256 accRewardPerShare;
        uint256 lastRewardBlock;
    }

    PoolInfo[] public poolInfoArray;

    struct UserInfo {
        uint256 rewardAmount;
        uint256 lastClaimTime;
    }

    mapping(address => UserInfo) public userInfoMap;

    struct UserPoolInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping(address => mapping(uint256 => UserPoolInfo)) public userPoolInfoMap;

    struct AssetInfo {
        address token;
        uint256 rate;
    }

    AssetInfo[] public assetInfoArray;

    struct UserAssetInfo {
        uint256 rewardAmount;
    }

    mapping(address => mapping(uint256 => UserAssetInfo)) public userAssetInfoMap;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function poolInfoArrayLength() external view returns (uint256) {
        return poolInfoArray.length;
    }

    function getMultiplier(
        address who_,
        uint256 assetIndex_
    ) public view returns(uint256) {
        return IMiningConfig(registry.miningConfig()).getMultiplier(who_, assetIndex_);
    }

    function getClaimAmount(
        address who_
    ) public view returns(uint256) {
        return IClaimConfig(registry.claimConfig()).getClaimAmount(who_);
    }

    function getClaimDuration(
        address who_
    ) public view returns(uint256) {
        return IClaimConfig(registry.claimConfig()).getClaimDuration(who_);
    }

    function stableToken() public view returns(address) {
        return registry.stableToken();
    }

    function canConsume(address who_) public view returns(bool) {
        return who_ == registry.ship() || who_ == registry.base() || who_ == registry.research();
    }

    function addPool(
        IFarm farm_,
        uint256 farmPid_,
        address token_,
        address rewardToken_
    ) public onlyOwner {
        poolInfoArray.push(PoolInfo({
            farm: farm_,
            farmPid: farmPid_,
            token: token_,
            rewardToken: rewardToken_,
            amount: 0,
            accRewardPerShare: 0,
            lastRewardBlock: 0
        }));
    }

    function addAsset(
        address token_,
        uint256 rate_
    ) public onlyOwner {
        assetInfoArray.push(AssetInfo({
            token: token_,
            rate: rate_
        }));
    }

    function _estimateRewardFromPool(IFarm farm, uint256 farmPid) public view returns(uint256) {
        return farm.pendingReward(farmPid);
    }

    // ***
    // We will trigger the "convert(address who_)" function for the big
    // stakers with a script as frequently as possible (say every hour)
    // so that the fromAmount_ is always small enough, to prevent sandwich attacks 
    // from happening.
    //
    // If the problem still exists, we will add oracle and upgrade the code, but 
    // at this point we don't want to overkill.
    //
    function _swapIntoStableToken(address fromToken_, uint256 fromAmount_) private returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = address(fromToken_);
        path[1] = address(stableToken());
        uint256 deadline = now + (1 hours);

        IERC20(fromToken_).approve(registry.uniswapV2Router(), 0);
        IERC20(fromToken_).approve(registry.uniswapV2Router(), fromAmount_);
        uint256[] memory amounts = IUniswapV2Router02(registry.uniswapV2Router()).swapExactTokensForTokens(
            fromAmount_,
            0,  // *
            path,
            registry.treasury(),
            deadline);
        return amounts[1];
    }

    function _estimateStableToken(address fromToken_, uint256 fromAmount_) private view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = address(fromToken_);
        path[1] = address(stableToken());
        uint256[] memory amounts = IUniswapV2Router02(registry.uniswapV2Router()).getAmountsOut(
            fromAmount_, path);
        return amounts[1];
    }

    function _processReward(uint256 pid_, uint256 amount_) private {
        if (amount_ == 0) {
            return;
        }

        PoolInfo storage pool = poolInfoArray[pid_];

        if (pool.rewardToken != stableToken()) {
            amount_ = _swapIntoStableToken(pool.rewardToken, amount_);
        }

        // Adds to accRewardPerShare.
        pool.accRewardPerShare = pool.accRewardPerShare.add(
            amount_.mul(UNIT_PER_SHARE).div(pool.amount));
    }

    function _estimatePoolAccRewardPerShare(uint256 pid_, uint256 amount_) private view returns(uint256) {
        PoolInfo storage pool = poolInfoArray[pid_];

        if (amount_ == 0) {
            return pool.accRewardPerShare;
        }

        if (pool.rewardToken != stableToken()) {
            amount_ = _estimateStableToken(pool.rewardToken, amount_);
        }

        return pool.accRewardPerShare.add(
            amount_.mul(UNIT_PER_SHARE).div(pool.amount));
    }

    function deposit0(uint256 pid_, uint256 amount_) external noReentry {
        PoolInfo storage pool = poolInfoArray[pid_];
        UserInfo storage user = userInfoMap[_msgSender()];
        UserPoolInfo storage userPool = userPoolInfoMap[_msgSender()][pid_];

        require(pool.token != address(0), "token is 0");
        require(pool.rewardToken != address(0), "reward token is 0");
        require(pool.token != pool.rewardToken, "Case not handled");

        uint256 balanceBefore = IERC20(pool.rewardToken).balanceOf(address(this));

        IERC20(pool.token).safeTransferFrom(_msgSender(), address(this), amount_);
        IERC20(pool.token).approve(address(pool.farm), 0);
        IERC20(pool.token).approve(address(pool.farm), amount_);
        pool.farm.deposit(pool.token, pool.farmPid, amount_);

        uint256 balanceAfter = IERC20(pool.rewardToken).balanceOf(address(this));
        uint256 rewardAmount = balanceAfter.sub(balanceBefore);

        _processReward(pid_, rewardAmount);

        if (userPool.amount > 0) {
            uint256 pending = userPool.amount.mul(pool.accRewardPerShare).div(UNIT_PER_SHARE).sub(userPool.rewardDebt);
            user.rewardAmount = user.rewardAmount.add(pending);
        }

        pool.amount = pool.amount.add(amount_);
        userPool.amount = userPool.amount.add(amount_);
        userPool.rewardDebt = userPool.amount.mul(pool.accRewardPerShare).div(UNIT_PER_SHARE);
    }

    function withdraw0(uint256 pid_, uint256 amount_) external noReentry {
        PoolInfo storage pool = poolInfoArray[pid_];
        UserInfo storage user = userInfoMap[_msgSender()];
        UserPoolInfo storage userPool = userPoolInfoMap[_msgSender()][pid_];

        require(pool.token != address(0), "token is 0");
        require(pool.rewardToken != address(0), "reward token is 0");
        require(pool.token != pool.rewardToken, "Case not handled");

        uint256 balanceBefore = IERC20(pool.rewardToken).balanceOf(address(this));

        pool.farm.withdraw(pool.token, pool.farmPid, amount_);
        IERC20(pool.token).safeTransfer(_msgSender(), amount_);

        uint256 balanceAfter = IERC20(pool.rewardToken).balanceOf(address(this));
        uint256 rewardAmount = balanceAfter.sub(balanceBefore);

        _processReward(pid_, rewardAmount);

        if (userPool.amount > 0) {
            uint256 pending = userPool.amount.mul(pool.accRewardPerShare).div(UNIT_PER_SHARE).sub(userPool.rewardDebt);
            user.rewardAmount = user.rewardAmount.add(pending);
        }

        pool.amount = pool.amount.sub(amount_);
        userPool.amount = userPool.amount.sub(amount_);
        userPool.rewardDebt = userPool.amount.mul(pool.accRewardPerShare).div(UNIT_PER_SHARE);
    }

    function _convert(address who_) private {
        UserInfo storage user = userInfoMap[who_];

        uint256 userRewardAmount = user.rewardAmount;

        // Process reward of all pools.

        for (uint256 pid = 0; pid < poolInfoArray.length; ++pid) {
            PoolInfo storage pool = poolInfoArray[pid];
            UserPoolInfo storage userPool = userPoolInfoMap[who_][pid];

            require(pool.token != pool.rewardToken, "Case not handled");

            if (userPool.amount == 0) {
                continue;
            }

            uint256 balanceBefore = IERC20(pool.rewardToken).balanceOf(address(this));

            // Claim rewards.
            pool.farm.claim(pool.farmPid);

            uint256 balanceAfter = IERC20(pool.rewardToken).balanceOf(address(this));
            uint256 rewardAmount = balanceAfter.sub(balanceBefore);

            _processReward(pid, rewardAmount);

            uint256 pending = userPool.amount.mul(pool.accRewardPerShare).div(UNIT_PER_SHARE).sub(userPool.rewardDebt);
            userRewardAmount = userRewardAmount.add(pending);

            userPool.rewardDebt = userPool.amount.mul(pool.accRewardPerShare).div(UNIT_PER_SHARE);
        }

        user.rewardAmount = 0;

        // Now convert reward to commodities.

        for (uint256 i = 0; i < assetInfoArray.length; ++i) {
            uint256 addedAmount = userRewardAmount.mul(
                assetInfoArray[i].rate).mul(
                    getMultiplier(who_, i)).div(
                        RATE_BASE).div(MULTIPLIER_BASE);
            userAssetInfoMap[who_][i].rewardAmount =
                userAssetInfoMap[who_][i].rewardAmount.add(addedAmount);
        }
    }

    function convert(address who_) external onlyEOA noReentry {
        _convert(who_);
    }

    function getPendingAssetAmount(address who_, uint256 assetIndex_) external view returns(uint256) {
        UserInfo storage user = userInfoMap[who_];

        uint256 userRewardAmount = user.rewardAmount;

        // Process reward of all pools.

        for (uint256 pid = 0; pid < poolInfoArray.length; ++pid) {
            PoolInfo storage pool = poolInfoArray[pid];
            UserPoolInfo storage userPool = userPoolInfoMap[who_][pid];

            require(pool.token != pool.rewardToken, "Case not handled");

            if (userPool.amount == 0) {
                continue;
            }

            uint256 rewardAmount = _estimateRewardFromPool(pool.farm, pool.farmPid);
            uint256 accRewardPerShare = _estimatePoolAccRewardPerShare(pid, rewardAmount);

            uint256 pending = userPool.amount.mul(accRewardPerShare).div(UNIT_PER_SHARE).sub(userPool.rewardDebt);
            userRewardAmount = userRewardAmount.add(pending);
        }

        // Now estimate commodities from reward.

        uint256 addedAmount = userRewardAmount.mul(
            assetInfoArray[assetIndex_].rate).mul(
                getMultiplier(who_, assetIndex_)).div(
                    RATE_BASE).div(MULTIPLIER_BASE);
        return userAssetInfoMap[who_][assetIndex_].rewardAmount.add(addedAmount);
    }

    function claim(uint256[] calldata amountArray_) external onlyEOA noReentry {
        require(amountArray_.length == assetInfoArray.length, "Size not equal");

        UserInfo storage user = userInfoMap[_msgSender()];
        require(now >= user.lastClaimTime + getClaimDuration(_msgSender()), "Not ready");

        // Convert before claiming.
        _convert(_msgSender());

        uint256 sum = 0;
        for (uint256 i = 0; i < amountArray_.length; ++i) {
            uint256 amount = amountArray_[i];
            sum = sum.add(amount);
            userAssetInfoMap[_msgSender()][i].rewardAmount =
                userAssetInfoMap[_msgSender()][i].rewardAmount.sub(amount);
            ICommodityERC20(assetInfoArray[i].token).mintByInternalContracts(_msgSender(), amount);
        }

        require(sum <= getClaimAmount(_msgSender()), "Claimed too many");

        user.lastClaimTime = now;
    }

    function userClaimStartTime() external view returns (uint256){
        UserInfo storage user = userInfoMap[_msgSender()];
        return user.lastClaimTime + getClaimDuration(_msgSender());
    }
}
