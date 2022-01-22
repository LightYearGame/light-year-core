// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../interface/IMiningConfig.sol";
import "../interface/IRegistry.sol";
import "../interface/IUpgradeable.sol";

contract MiningConfig is IMiningConfig {
    using SafeMath for uint256;

    IRegistry public registry;

    constructor(IRegistry registry_) public {
        registry = registry_;
    }

    function base() public view returns (IUpgradeable) {
        return IUpgradeable(registry.base());
    }

    function getMultiplier(
        address who_,
        uint256 assetIndex_
    ) external override view returns (uint256) {
        uint256 baseMultiplier = base().levelMap(who_, 0).mul(3).add(100);
        uint256 assetMultiplier = base().levelMap(who_, assetIndex_.add(1)).mul(3).add(100);
        return baseMultiplier.mul(assetMultiplier).mul(1e5);
    }
}
