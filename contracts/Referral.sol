// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interface/IRegistry.sol";
import "./interface/ICommodityERC20.sol";

contract Referral is Ownable {

    uint256 constant UNIT_AMOUNT = 1e14;

    IRegistry public registry;

    mapping(address => bool) public authorized;
    mapping(address => address) public referredBy;
    mapping(address => uint256) public firstTime;
    mapping(address => uint256) public tier1Count;
    mapping(address => uint256) public tier2Count;

    struct Reward {
        uint64 iron;
        uint64 gold;
        uint64 silicate;
        uint64 energy;
    }

    mapping(address => Reward) public rewardMap;

    event OnReward(address indexed from_, address indexed to_, uint8 indexed tier_,
        uint64 iron_, uint64 gold_, uint64 silicate_, uint64 energy_);

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function setAuthorized(address which_, bool value_) external onlyOwner {
        authorized[which_] = value_;
    }

    function tier1Referral(address who_) public view returns(address) {
        return referredBy[who_];
    }

    function tier2Referral(address who_) public view returns(address) {
        return referredBy[referredBy[who_]];
    }

    function setReferral(address who_, address byWhom_) external {
        require(_msgSender() == owner() ||
                _msgSender() == who_ ||
                authorized[_msgSender()], "No access");
        require(referredBy[who_] == address(0), "Already set");

        if (_msgSender() == who_) {
            require(firstTime[who_] == 0 || firstTime[who_] + (1 days) > now, "Too late");
        }

        if (firstTime[who_] == 0) {
            firstTime[who_] = now;
        }

        referredBy[who_] = byWhom_;

        if (byWhom_ != address(0)) {
            ++tier1Count[byWhom_];

            address tier2 = referredBy[byWhom_];
            if (tier2 != address(0)) {
                ++tier2Count[tier2];
            }
        }
    }

    function onReward(address who_, uint256[] calldata amountArray_) external {
        require(authorized[_msgSender()], "Only authorized");
        require(amountArray_.length == 4, "Invalid array");

        address tier1 = tier1Referral(who_);
        address tier2 = tier2Referral(who_);
        Reward storage oldReward;
        Reward memory reward;

        if (tier1 != address(0)) {
            oldReward = rewardMap[tier1];
            reward = Reward(
                oldReward.iron + uint64(amountArray_[0] * 7 / 100 / UNIT_AMOUNT),
                oldReward.gold + uint64(amountArray_[1] * 7 / 100 / UNIT_AMOUNT),
                oldReward.silicate + uint64(amountArray_[2] * 7 / 100 / UNIT_AMOUNT),
                oldReward.energy + uint64(amountArray_[3] * 7 / 100 / UNIT_AMOUNT)
            );
            rewardMap[tier1] = reward;
            emit OnReward(who_, tier1, uint8(1), reward.iron, reward.gold, reward.silicate, reward.energy);
        }

        if (tier2 != address(0)) {
            oldReward = rewardMap[tier2];
            reward = Reward(
                oldReward.iron + uint64(amountArray_[0] * 2 / 100 / UNIT_AMOUNT),
                oldReward.gold + uint64(amountArray_[1] * 2 / 100 / UNIT_AMOUNT),
                oldReward.silicate + uint64(amountArray_[2] * 2 / 100 / UNIT_AMOUNT),
                oldReward.energy + uint64(amountArray_[3] * 2 / 100 / UNIT_AMOUNT)
            );
            rewardMap[tier2] = reward;
            emit OnReward(who_, tier2, uint8(2), reward.iron, reward.gold, reward.silicate, reward.energy);
        }
    }

    function claim() external {
        Reward storage reward = rewardMap[_msgSender()];
        if (reward.iron > 0) {
            ICommodityERC20(registry.tokenIron()).mintByInternalContracts(_msgSender(), reward.iron * UNIT_AMOUNT);
            reward.iron = 0;
        }

        if (reward.gold > 0) {
            ICommodityERC20(registry.tokenGold()).mintByInternalContracts(_msgSender(), reward.gold * UNIT_AMOUNT);
            reward.gold = 0;
        }

        if (reward.silicate > 0) {
            ICommodityERC20(registry.tokenSilicate()).mintByInternalContracts(_msgSender(), reward.silicate * UNIT_AMOUNT);
            reward.silicate = 0;
        }

        if (reward.energy > 0) {
            ICommodityERC20(registry.tokenEnergy()).mintByInternalContracts(_msgSender(), reward.energy * UNIT_AMOUNT);
            reward.energy = 0;
        }
    }
}
