// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface/IRegistry.sol";

contract SoftStaking is Ownable {

    using SafeMath for uint256;

    IRegistry public registry;

    uint256 public delay = 24 hours;

    mapping(address => uint256) public balanceMap;
    mapping(address => uint256) public timeMap;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function setDelay(uint256 delay_) external onlyOwner {
        delay = delay_;
    }

    function deposit(uint256 amount_) external {
        IERC20(registry.tokenLightCoin()).transferFrom(
            _msgSender(), address(this), amount_);
        balanceMap[_msgSender()] = balanceMap[_msgSender()].add(amount_);
        timeMap[_msgSender()] = now;
    }

    function withdraw(uint256 amount_) external {
        require(now > timeMap[_msgSender()] + delay, "Wait");
        require(amount_ <= balanceMap[_msgSender()], "Not enough balance");
        IERC20(registry.tokenLightCoin()).transfer(
            _msgSender(), amount_);
        balanceMap[_msgSender()] = balanceMap[_msgSender()].sub(amount_);
    }
}
