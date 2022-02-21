// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

interface IPancakeChef {
    function cake() external view returns(address);
    function cakePerBlock() external view returns(uint256);
    function totalAllocPoint() external view returns(uint256);
    function poolInfo(uint256 _pid) external view returns(
        address, uint256, uint256, uint256);
}

contract PairPriceHelper {

    uint256 constant PRICE_BASE = 1e18;

    address wbnb;
    address busd;
    address lpwbnbbusd;

    constructor (address wbnb_, address busd_, address lpwbnbbusd_) public {
        wbnb = wbnb_;
        busd = busd_;
        lpwbnbbusd = lpwbnbbusd_;
    }

    function getWbnbPrice() public view returns(uint256) {
        uint256 busdAmount = IERC20(busd).balanceOf(lpwbnbbusd);
        uint256 wbnbAmount = IERC20(wbnb).balanceOf(lpwbnbbusd);
        return busdAmount * PRICE_BASE / wbnbAmount;
    }

    function getPairPrice(address lpToken_) public view returns(uint256) {
        uint256 lpAmount = IUniswapV2Pair(lpToken_).totalSupply();
        address token0 = IUniswapV2Pair(lpToken_).token0();
        address token1 = IUniswapV2Pair(lpToken_).token1();

        if (token0 == busd || token1 == busd) {
            uint256 busdAmount = IERC20(busd).balanceOf(lpToken_);
            return busdAmount * 2 * PRICE_BASE / lpAmount;
        } else if (token0 == wbnb || token1 == wbnb) {
            uint256 wbnbAmount = IERC20(wbnb).balanceOf(lpToken_);
            return wbnbAmount * 2 * getWbnbPrice() / lpAmount;
        } else {
            require(false, "Unsupported");
        }
    }

    function getTokenPrice(address lpTokenBUSD_, address token_) public view returns(uint256) {
        uint256 busdAmount = IERC20(busd).balanceOf(lpTokenBUSD_);
        uint256 tokenAmount = IERC20(token_).balanceOf(lpTokenBUSD_);
        return busdAmount * PRICE_BASE / tokenAmount;
    }

    function getTotalRewardToken(IPancakeChef chef_, uint256 pid_) public view returns(uint256) {
        (, uint256 poolAlloc, ,) = chef_.poolInfo(pid_);
        return chef_.cakePerBlock() * poolAlloc / chef_.totalAllocPoint() * 28800 * 365;
    }

    function getTotalRewardValue(address lpTokenBUSD_, IPancakeChef chef_, uint256 pid_) public view returns(uint256) {
        uint256 totalToken = getTotalRewardToken(chef_, pid_);
        return totalToken * getTokenPrice(lpTokenBUSD_, chef_.cake()) / PRICE_BASE;
    }

    function getMasterChefPrinciple(IPancakeChef chef_, uint256 pid_) public view returns(uint256) {
        (address token, , ,) = chef_.poolInfo(pid_);
        return IERC20(token).balanceOf(address(chef_)) * getPairPrice(token) / PRICE_BASE;
    }

    function getMasterChefApr(address lpTokenBUSD_, IPancakeChef chef_, uint256 pid_) public view returns(uint256) {
        uint256 totalValue = getTotalRewardValue(lpTokenBUSD_, chef_, pid_);
        uint256 totalPrinciple = getMasterChefPrinciple(chef_, pid_);
        return totalValue * 10000 / totalPrinciple;
    }

    function getPancakeApr(uint256 pid_) external view returns(uint256) {
        return getMasterChefApr(0x804678fa97d91B974ec2af3c843270886528a9E6,
            IPancakeChef(address(0x73feaa1eE314F8c655E354234017bE2193C9E24E)),
            pid_);
    }

    function getApeswapApr(uint256 pid_) external view returns(uint256) {
        return getMasterChefApr(0x7Bd46f6Da97312AC2DBD1749f82E202764C0B914,
            IPancakeChef(address(0x5c8D727b265DBAfaba67E050f2f739cAeEB4A6F9)),
            pid_);
    }
}
