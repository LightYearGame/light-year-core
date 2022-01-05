// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../interface/IClaimConfig.sol";
import "../interface/IRegistry.sol";
import "../interface/IUpgradeable.sol";

contract ClaimConfig is IClaimConfig {

    IRegistry public registry;

    constructor(IRegistry registry_) public {
        registry = registry_;
    }

    function research() public view returns(IUpgradeable) {
        return IUpgradeable(registry.research());
    }

    function getClaimAmount(address who_) external override view returns(uint256) {
        return 128 * (2 ** research().levelMap(who_, 0)) * 1e18;
    }

    function getClaimDuration(address who_) external override view returns(uint256) {
        return (12 hours);
    }
}
