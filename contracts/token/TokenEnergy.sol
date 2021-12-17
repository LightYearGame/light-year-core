// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./CommodityERC20.sol";

contract TokenEnergy is CommodityERC20 {

    constructor(address registry_) public CommodityERC20("LightYearEnergy", "LYENERGY", registry_) {}
}