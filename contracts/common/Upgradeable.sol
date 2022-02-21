// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../interface/IUpgradeable.sol";
import "../interface/IUpgradeableConfig.sol";
import "../interface/IRegistry.sol";
import "../interface/ICommodityERC20.sol";

abstract contract Upgradeable is IUpgradeable, Context {

    using SafeERC20 for ICommodityERC20;

    IRegistry public registry;

    mapping(address => mapping(uint256 => uint256)) public override levelMap;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function _config() internal virtual view returns (IUpgradeableConfig);

    function upgrade(uint256 itemIndex_) external override {
        require(itemIndex_ < _config().maximumIndex(), "Wrong index");

        uint256 level = levelMap[_msgSender()][itemIndex_];
        require(level < _config().maximumLevel(itemIndex_), "Wrong level");

        address[] memory tokenArray = _config().getTokenArray(itemIndex_, level);
        uint256[] memory costArray = _config().getCostArray(itemIndex_, level);

        for (uint256 i = 0; i < tokenArray.length; ++i) {
            if (costArray[i] > 0) {
                ICommodityERC20(tokenArray[i]).transferFrom(_msgSender(), address(this), costArray[i]);
                ICommodityERC20(tokenArray[i]).burn(costArray[i]);
            }
        }

        levelMap[_msgSender()][itemIndex_] = level + 1;
    }
}
