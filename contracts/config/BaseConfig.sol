// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interface/IRegistry.sol";
import "../interface/IUpgradeableConfig.sol";


contract BaseConfig is IUpgradeableConfig {
    using SafeMath for uint256;

    // 0 - base level
    // 1 to 4 - asset levels.
    // Check MiningConfig.

    IRegistry public registry;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function maximumLevel(uint256 itemIndex_) external override view returns (uint256) {
        return 100;
    }

    function getTokenArray(uint256 itemIndex_, uint256 level_) external override view returns (address[] memory) {
        address[] memory result = new address[](2);

        if (itemIndex_ == 0) {
            result[0] = registry.tokenSilicate();
            result[1] = registry.tokenEnergy();
        } else {
            result[0] = registry.tokenSilicate();
            result[1] = registry.tokenEnergy();
        }

        return result;
    }

    function getCostArray(uint256 itemIndex_, uint256 level_) external override view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](2);
        if (itemIndex_ == 0) {
            result[0] = (2 ** level_).mul(200).mul(1e18);
            result[1] = (2 ** level_).mul(200).mul(1e18);
        } else {
            result[0] = (2 ** level_).mul(150).mul(1e18);
            result[1] = (2 ** level_).mul(150).mul(1e18);
        }
        return result;
    }
}
