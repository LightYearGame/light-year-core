// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../interface/IRegistry.sol";
import "../interface/IUpgradeableConfig.sol";

contract ResearchConfig is IUpgradeableConfig {
    using SafeMath for uint256;

    // 0 - Research
    // 1 - Laser Beam
    // 2 - Nuclear Fusion
    // 3 - Quantum Chemistry
    // 4 - Dark Matter
    // 5 - Gene Mutation

    IRegistry public registry;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function maximumIndex() public override view returns (uint256) {
        return 6;
    }

    function maximumLevel(uint256 itemIndex_) public override view returns (uint256) {
        return 6;
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
