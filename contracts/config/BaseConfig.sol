// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../interface/IRegistry.sol";
import "../interface/IUpgradeableConfig.sol";


contract BaseConfig is IUpgradeableConfig {

    // 0 - base level
    // 1 to 4 - asset levels.
    // Check MiningConfig.

    IRegistry public registry;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function maximumLevel(uint256 itemIndex_) external override view returns(uint256) {
        return 100;
    }

    function getTokenArray(uint256 itemIndex_, uint256 level_) external override view returns(address[] memory) {
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

    function getCostArray(uint256 itemIndex_, uint256 level_) external override view returns(uint256[] memory) {
        uint256[] memory result = new uint256[](2);
        if(itemIndex_== 0){
            result[0] = 100 * (2 ** level_);
            result[1] = 100 * (2 ** level_);
        }else{
            result[0] = (level_ + 1) * 75;
            result[1] = (level_ + 1) * 85;
        }
        return result;
    }
}
