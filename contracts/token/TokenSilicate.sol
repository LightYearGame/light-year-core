// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./CommodityERC20.sol";

contract TokenSilicate is CommodityERC20 {

    constructor(address registry_) public CommodityERC20("LightYearSilicate", "LYSILICATE", registry_) {}
}