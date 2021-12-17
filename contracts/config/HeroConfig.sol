// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./../interface/IHeroConfig.sol";

contract HeroConfig is IHeroConfig {

    address public registryAddress;

    constructor(address registry_) public {
        registryAddress = registry_;
    }

    function getHeroPrice() public pure override returns (uint256){
        return 0.06 ether;
    }

    function getAttribute(uint256) public pure override returns (uint256){
        return 200;
    }
}