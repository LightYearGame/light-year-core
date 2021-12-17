// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./CommodityERC20.sol";

contract TokenIron is CommodityERC20 {

    constructor(address registry_) public CommodityERC20("LightYearIron", "LYIRON", registry_) {}
}