// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../interface/IRegistry.sol";
import "../interface/IUpgradeableConfig.sol";
import "../common/Upgradeable.sol";

contract Research is Upgradeable {

    constructor (IRegistry registry_) Upgradeable(registry_) public {
    }

    function _config() internal override view returns(IUpgradeableConfig) {
        return IUpgradeableConfig(registry.researchConfig());
    }
}
