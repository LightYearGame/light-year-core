// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./interface/IRegistry.sol";
import "./interface/ICommodityERC20.sol";
import "./interface/ILightCoin.sol";
import "./interface/IMiningConfig.sol";

contract SoftStakingV1 is Ownable {

    using SafeMath for uint256;

    uint256 constant UNIT_PER_SHARE = 1e18;
    uint256 constant MULTIPLIER_BASE = 8e10;

    IRegistry public registry;

    uint256 public delay = 24 hours;
    uint256 public rewardPerSecond = 57e9;

    struct Info {
        uint256 balance;
        uint256 time;
        uint256 unclaimed;
    }

    mapping(address => Info) public infoMap;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function setDelay(uint256 delay_) external onlyOwner {
        delay = delay_;
    }

    function setRewardPerSecond(uint256 value_) external onlyOwner {
        rewardPerSecond = value_;
    }

    function getMultiplier(
        address who_
    ) public view returns (uint256) {
        return IMiningConfig(registry.miningConfig()).getMultiplier(who_, 3);
    }

    function _update(address who_) private {
        Info storage info = infoMap[who_];

        if (info.time > 0) {
            info.unclaimed = info.unclaimed.add(
                now.sub(info.time).mul(rewardPerSecond).mul(
                    info.balance).mul(getMultiplier(who_)).div(
                        UNIT_PER_SHARE).div(MULTIPLIER_BASE));
        }

        info.time = now;
    }

    function deposit(uint256 amount_) external {
        Info storage info = infoMap[_msgSender()];

        //update unclaimed amount
        _update(_msgSender());

        ILightCoin(registry.tokenLightCoin()).transferFrom(
            _msgSender(), address(this), amount_);
        info.balance = info.balance.add(amount_);
    }

    function withdraw(uint256 amount_) external {
        Info storage info = infoMap[_msgSender()];

        require(now > info.time + delay, "Wait");
        require(amount_ <= info.balance, "Not enough balance");

        //update unclaimed amount
        _update(_msgSender());

        ILightCoin(registry.tokenLightCoin()).transfer(
            _msgSender(), amount_);
        info.balance = info.balance.sub(amount_);
    }

    function snatch(address from_, address to_, uint256 amount_, uint256 fee_) external {
        require(_msgSender() == registry.fleets() ||
                _msgSender() == registry.battle() ||
                _msgSender() == registry.explore(), "Only call from authorized contracts");
        _update(from_);
        _update(to_);

        infoMap[from_].balance = infoMap[from_].balance.sub(amount_).sub(fee_);
        infoMap[to_].balance = infoMap[to_].balance.add(amount_);
        ILightCoin(registry.tokenLightCoin()).burn(fee_);
    }

    function claim() external {
        Info storage info = infoMap[_msgSender()];

        //update unclaimed amount
        _update(_msgSender());

        ICommodityERC20(registry.tokenEnergy()).mintByInternalContracts(
            _msgSender(), info.unclaimed);
        info.unclaimed = 0;
    }

    function expectedAmount() external view returns (uint256){
        return expectedAmountOfUser(_msgSender());
    }

    function expectedAmountOfUser(address who_) public view returns (uint256){
        Info storage info = infoMap[who_];

        return info.unclaimed.add(
            now.sub(info.time).mul(rewardPerSecond).mul(
                info.balance).mul(getMultiplier(who_)).div(
                    UNIT_PER_SHARE).div(MULTIPLIER_BASE));
    }
}
