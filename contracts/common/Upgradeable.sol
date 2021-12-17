// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../interface/IUpgradeable.sol";
import "../interface/IUpgradeableConfig.sol";
import "../interface/IRegistry.sol";

interface IBurnableERC20 is IERC20 {
    function burn(address who_, uint256 amount_) external;
}

abstract contract Upgradeable is IUpgradeable, Context {

    using SafeERC20 for IBurnableERC20;

    IRegistry public registry;

    mapping(address => mapping(uint256 => uint256)) public override levelMap;

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function _config() internal virtual view returns (IUpgradeableConfig);

    function upgrade(uint256 itemIndex_) external override {
        uint256 level = levelMap[_msgSender()][itemIndex_];
        require(level < _config().maximumLevel(itemIndex_));

        address[] memory tokenArray = _config().getTokenArray(itemIndex_, level);
        uint256[] memory costArray = _config().getCostArray(itemIndex_, level);
        for (uint256 i = 0; i < tokenArray.length; ++i) {
            //IBurnableERC20(tokenArray[i]).safeTransferFrom(_msgSender(), address(this), costArray[i]);
            IBurnableERC20(tokenArray[i]).burn(_msgSender(), costArray[i]);
        }

        levelMap[_msgSender()][itemIndex_] = level + 1;
    }

    function size() public override view returns (uint256){
        return 0;
    }
}
