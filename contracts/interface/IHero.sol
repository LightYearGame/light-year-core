// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

interface IHero {

    struct Info {
        uint16 level;
        uint8 heroType;
    }

    function operatorTransfer(address from, address to, uint256 tokenId) external;

    function heroOwnerOf(uint256 shipId) external view returns (address);

    function heroInfo(uint256 shipId) external view returns (Info memory);
}