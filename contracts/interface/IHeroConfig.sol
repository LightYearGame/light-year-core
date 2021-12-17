// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IHeroConfig {

    function getHeroPrice() external pure returns (uint256);

    function getAttribute(uint256 shipId_) external pure returns (uint256);
}