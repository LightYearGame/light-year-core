// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

interface IShip {

    struct Info {
        uint8 level;
        uint8 quality;
        uint8 shipType;
    }

    function shipInfo(uint256 shipId_) external view returns(Info memory);
    function buildShip(uint8 shipType_) external;
    function upgradeShip(uint256 shipFromTokenId_, uint256 shipToTokenId_) external;
}
