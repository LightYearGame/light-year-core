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

    function maximumIndex() public override view returns (uint256) {
        return 5;
    }

    function maximumLevel(uint256 itemIndex_) public override view returns (uint256) {
        return 8;
    }

    function getTokenArray(uint256 itemIndex_, uint256 level_) external override view returns (address[] memory) {
        address[] memory result = new address[](1);
        result[0] = registry.tokenSilicate();
        return result;
    }

    function getCostArray(uint256 itemIndex_, uint256 level_) external override view returns (uint256[] memory) {
        require(itemIndex_ < maximumIndex(), "Wrong index");
        require(level_ < maximumLevel(itemIndex_), "Wrong level");

        uint256[] memory result = new uint256[](1);

        if (itemIndex_ == 0) {
            result[0] = (4 ** level_).mul(200e18);
        } else {
            result[0] = (4 ** level_).mul(100e18);
        }

        return result;
    }
}
