// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./CommodityERC20.sol";

contract TokenLightCoin is CommodityERC20 {

    constructor(uint256 supply_,address registry_) public CommodityERC20("LightCoin", "LC", registry_) {
        mint(_msgSender(), supply_);
    }
}