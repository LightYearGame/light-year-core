// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IHeroConfig {

    function getHeroPrice(bool advance_) external pure returns (uint256);

    function configs(uint256 key_) external view returns (uint256);

    function randomHeroType(bool advance_, uint256 random_) external view returns (uint256);
}