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
        uint256 baseLevel = base().levelMap(who_, 0);
        uint256 baseMultiplier = 100 * (11 ** baseLevel) / (10 ** baseLevel);
        uint256 assetLevel = base().levelMap(who_, assetIndex_.add(1));
        uint256 assetMultiplier = 100 * (11 ** assetLevel) / (10 ** assetLevel);
        return baseMultiplier.mul(assetMultiplier).mul(8e6);
    }
}
