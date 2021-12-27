// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILightCoin is IERC20 {

    function burn(uint256 amount_) external;
}
