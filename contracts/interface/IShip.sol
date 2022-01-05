// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

interface IShip {

    struct Info {
        uint16 level;
        uint8 quality;
        uint8 shipType;
    }

    function operatorTransfer(address from, address to, uint256 tokenId) external;
    function shipInfo(uint256 shipId) external view returns(Info memory);
    function upgradeShip(uint256 shipFromTokenId_, uint256 shipToTokenId_) external;
}
