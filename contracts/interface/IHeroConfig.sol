// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./IHero.sol";

interface IHeroConfig {
    function getHeroPrice(bool advance_) external pure returns (uint256);
    function randomHeroType(bool advance_, uint256 seed_) external view returns (uint8);
    function randomHeroTypeRarier(uint8 heroType_, uint256 seed_) external view returns (uint8);
    function randomHeroQuality(uint256 seed_) external view returns (uint8);
}
