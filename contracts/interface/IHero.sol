// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

interface IHero {

    struct Info {
        uint16 level;
        uint8 quality;
        uint8 heroType;
    }

    function operatorTransfer(address from, address to, uint256 tokenId) external;
    function heroInfo(uint256 shipId) external view returns (Info memory);
    function upgradeHero(uint256 heroId_) external;
}
