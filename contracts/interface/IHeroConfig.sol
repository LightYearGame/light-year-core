// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./IHero.sol";

interface IHeroConfig {

    function getHeroPrice(bool advance_) external pure returns (uint256);

    function configs(uint256 key_) external view returns (uint256);

    function randomHeroType(bool advance_, uint256 random_) external view returns (uint256);

    function getAttributesById(uint256 heroId_) external view returns (uint256[] memory);

    function getAttributesByInfo(IHero.Info memory info_) external view returns (uint256[] memory);
}