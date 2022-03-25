// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface/IRegistry.sol";
import "./interface/ICommodityERC20.sol";

contract SoftStakingV1 is Ownable {

    using SafeMath for uint256;

    IRegistry public registry;

    uint256 public delay = 24 hours;

    mapping(address => Info) public infoMap;

    struct Info {
        uint256 balance;
        uint256 time;
        uint256 unclaimed;
    }

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function setDelay(uint256 delay_) external onlyOwner {
        delay = delay_;
    }

    function deposit(uint256 amount_) external {
        //update unclaimed amount
        update();

        IERC20(registry.tokenLightCoin()).transferFrom(
            _msgSender(), address(this), amount_);
        infoMap[_msgSender()].balance = infoMap[_msgSender()].balance.add(amount_);
        infoMap[_msgSender()].time = now;
    }

    function withdraw(uint256 amount_) external {
        require(now > infoMap[_msgSender()].time + delay, "Wait");
        require(amount_ <= infoMap[_msgSender()].balance, "Not enough balance");

        //update unclaimed amount
        update();

        IERC20(registry.tokenLightCoin()).transfer(
            _msgSender(), amount_);
        infoMap[_msgSender()].balance = infoMap[_msgSender()].balance.sub(amount_);
    }

    function update() public {
        if (infoMap[_msgSender()].time > 0) {
            infoMap[_msgSender()].unclaimed += (now - infoMap[_msgSender()].time) * 57e9 * infoMap[_msgSender()].balance / 1e18;
            infoMap[_msgSender()].time = now;
        }
    }

    function claim() external {
        //update unclaimed amount
        update();

        ICommodityERC20(registry.tokenEnergy()).mintByInternalContracts(_msgSender(), infoMap[_msgSender()].unclaimed);
        infoMap[_msgSender()].unclaimed = 0;
    }

    function expectedAmount() external view returns (uint256){
        return infoMap[_msgSender()].unclaimed + (now - infoMap[_msgSender()].time) * 57e9 * infoMap[_msgSender()].balance / 1e18;
    }
}
