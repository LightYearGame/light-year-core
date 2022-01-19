// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "./interface/ILightCoin.sol";
import "./interface/IRegistry.sol";

contract Treasury is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 constant RATIO_BASE = 100;

    IRegistry public registry;

    address public dev;
    uint256 public rationToBurn = 80;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    modifier onlyEOA() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(msg.sender == tx.origin, "Must use EOA");
        _;
    }

    function setDev(address dev_) external onlyOwner {
      dev = dev_;
    }

    function setRatioToBurn(uint256 ratio_) external onlyOwner {
      require(ratio_ < RATIO_BASE);
      rationToBurn = ratio_;
    }

    // ***
    // The function will be triggered as frequently as possible (say every hour)
    // so that the amount_ is always small enough, to prevent sandwich attacks
    // from happening.
    //
    // If the problem still exists, we will add oracle and upgrade the code, but
    // at this point we don't want to overkill.
    //
    function process(uint256 amount_) external onlyEOA {
        uint256 balance = IERC20(registry.stableToken()).balanceOf(address(this));
        require(amount_ <= balance, "more than balance");
        require(dev != address(0), "Dev is 0x0");

        uint256 swapAmount = amount_.mul(rationToBurn).div(RATIO_BASE);
        uint256 devAmount = amount_.sub(swapAmount);

        IERC20(registry.stableToken()).safeTransfer(dev, devAmount);

        // Swap into LC and burn.
        address[] memory path = new address[](2);
        path[0] = address(registry.stableToken());
        path[1] = address(registry.tokenLightCoin());
        uint256 deadline = now + (1 hours);

        IERC20(registry.stableToken()).approve(registry.uniswapV2Router(), 0);
        IERC20(registry.stableToken()).approve(registry.uniswapV2Router(), amount_);
        uint256[] memory amounts = IUniswapV2Router02(registry.uniswapV2Router()).swapExactTokensForTokens(
            swapAmount,
            0,  // ***
            path,
            registry.treasury(),
            deadline);

        ILightCoin(registry.tokenLightCoin()).burn(amounts[1]);
    }
}
