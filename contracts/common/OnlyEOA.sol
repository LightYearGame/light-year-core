// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract OnlyEOA {

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Must use EOA");
        _;
    }
}
