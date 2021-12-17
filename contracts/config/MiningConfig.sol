// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../interface/IMiningConfig.sol";
import "../interface/IRegistry.sol";
import "../interface/IUpgradeable.sol";

contract MiningConfig is IMiningConfig {

    IRegistry public registry;

    constructor(IRegistry registry_) public {
        registry = registry_;
    }

    function base() public view returns(IUpgradeable) {
        return IUpgradeable(registry.base());
    }

    function getMultiplier(
        address who_,
        uint256 assetIndex_
    ) external override view returns(uint256) {
        return (100 + base().levelMap(who_, 0)) *
            (100 + base().levelMap(who_, assetIndex_ + 1));
    }
}
