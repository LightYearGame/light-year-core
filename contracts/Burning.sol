// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./interface/ICommodityERC20.sol";
import "./interface/IRegistry.sol";

contract Burning is Ownable {

    using SafeMath for uint256;

    IRegistry public registry;

    mapping(address => uint256) public burningBonusPerToken;

    // date => bonusPerToken
    mapping(uint256 => uint256) public bonusPerTokenMap;
    // token => date => count
    mapping(address => mapping(uint256 => uint256)) public totalMap;
    // token => date => who => count
    mapping(address => mapping(uint256 => mapping(address => uint256))) public userMap;

    event Burn(address indexed token_, uint256 indexed date_, address indexed who_, uint256 amount_);
    event Claim(address indexed token_, uint256 indexed date_, address indexed who_, uint256 amount_);
    event ClaimAll(uint256 indexed fromDate_, uint256 indexed toDate_, address indexed who_, uint256 amount_);

    constructor (IRegistry registry_) public {
        registry = registry_;
    }

    function setBurningBonusPerToken(address token_, uint256 value_) external onlyOwner {
        burningBonusPerToken[token_] = value_;
    }

    function getToday() public view returns(uint256) {
        return now / (24 hours);
    }

    function isCommodity(address token_) public view returns(bool) {
        return token_ == registry.tokenIron() ||
            token_ == registry.tokenGold() ||
            token_ == registry.tokenEnergy() ||
            token_ == registry.tokenSilicate();
    }

    function getCommodityArray() public view returns(address[] memory) {
        address[] memory array = new address[](4);
        array[0] = registry.tokenIron();
        array[1] = registry.tokenGold();
        array[2] = registry.tokenEnergy();
        array[3] = registry.tokenSilicate();
        return array;
    }

    function burn(address token_, uint256 amount_) external {
        require(isCommodity(token_), "Not commodity");

        ICommodityERC20(token_).operatorTransfer(_msgSender(), address(this), amount_);
        ICommodityERC20(token_).burn(amount_);

        uint256 today = getToday();

        totalMap[token_][today] = totalMap[token_][today].add(amount_);
        userMap[token_][today][_msgSender()] = userMap[token_][today][_msgSender()].add(amount_);

        emit Burn(token_, today, _msgSender(), amount_);
    }

    function getBonus(
        address token_,
        uint256 date_,
        address who_
    ) public view returns(uint256) {
        if (totalMap[token_][date_] == 0) {
            return 0;
        }

        uint256 bonusPerToken = bonusPerTokenMap[date_] > 0 ?
            bonusPerTokenMap[date_] : burningBonusPerToken[token_];

        return bonusPerToken.mul(
            userMap[token_][date_][who_]).div(
                totalMap[token_][date_]);
    }

    function getBonusAll(
        uint256 fromDate_,
        uint256 toDate_,
        address who_
    ) external view returns(uint256) {
        address[] memory commodityArray = getCommodityArray();

        uint256 total = 0;
        for (uint256 i = 0; i < commodityArray.length; ++i) {
            for (uint256 date = fromDate_; date < toDate_; ++date) {
                total = total.add(getBonus(commodityArray[i], date, who_));
            }
        }

        return total;
    }

    function claim(address token_, uint256 date_) external {
        require(isCommodity(token_), "Not commodity");

        uint256 today = getToday();
        require(today > date_, "Not ready");

        require(totalMap[token_][date_] > 0, "No burning");

        if (bonusPerTokenMap[date_] == 0) {
            bonusPerTokenMap[date_] = burningBonusPerToken[token_];
        }

        uint256 amount = getBonus(token_, date_, _msgSender());
        userMap[token_][date_][_msgSender()] = 0;
        IERC20(registry.tokenLightCoin()).transfer(_msgSender(), amount);

        emit Claim(token_, date_, _msgSender(), amount);
    }

    function claimAll(uint256 fromDate_, uint256 toDate_) external {
        uint256 today = getToday();
        require(today >= toDate_, "Not ready");

        address[] memory commodityArray = getCommodityArray();

        uint256 total = 0;

        for (uint256 i = 0; i < commodityArray.length; ++i) {
            address token = commodityArray[i];

            for (uint256 date = fromDate_; date < toDate_; ++date) {
                if (totalMap[token][date] == 0) {
                    continue;
                }

                if (bonusPerTokenMap[date] == 0) {
                    bonusPerTokenMap[date] = burningBonusPerToken[token];
                }

                total = total.add(getBonus(token, date, _msgSender()));
                userMap[token][date][_msgSender()] = 0;
            }
        }

        IERC20(registry.tokenLightCoin()).transfer(_msgSender(), total);

        emit ClaimAll(fromDate_, toDate_, _msgSender(), total);
    }
}
