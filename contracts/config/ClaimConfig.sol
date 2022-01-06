// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interface/IClaimConfig.sol";
import "../interface/IRegistry.sol";
import "../interface/IUpgradeable.sol";

contract ClaimConfig is IClaimConfig {
    using SafeMath for uint256;

    IRegistry public registry;

    constructor(IRegistry registry_) public {
        registry = registry_;
    }

    function research() public view returns(IUpgradeable) {
        return IUpgradeable(registry.research());
    }

    function getClaimAmount(address who_) external override view returns(uint256) {
        uint256 base = 128;
        return base.mul(1e18).mul(2 ** research().levelMap(who_, 0));
    }

    function getClaimDuration(address who_) external override view returns(uint256) {
        return (12 hours);
    }
}
