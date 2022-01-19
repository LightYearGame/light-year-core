// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract NoReentry {

    uint256 private unlocked = 1;

    modifier noReentry() {
        require(unlocked == 1, 'no re-entry');
        unlocked = 0;
        _;
        unlocked = 1;
    }
}
