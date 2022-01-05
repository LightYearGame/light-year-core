// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./../interface/IHeroConfig.sol";
import "./../interface/IRegistry.sol";
import "./../interface/IHero.sol";

contract HeroConfig is IHeroConfig {

    address public registryAddress;

    constructor(address registry_) public {
        registryAddress = registry_;
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function hero() private view returns (IHero){
        return IHero(registry().hero());
    }

    mapping(uint256 => uint256) public override configs;

    function setConfig(uint256 key_, uint256 value_) public returns (uint256){
        configs[key_] = value_;
    }

    function getHeroPrice(bool advance_) public pure override returns (uint256){
        if (advance_) {
            return 10000 * 1e18;
        } else {
            return 1000 * 1e18;
        }
    }

    function randomHeroType(bool advance_, uint256 seed_) public view override returns (uint8) {
        uint256 random = _random(seed_, 1e18);
        uint8 r1 = uint8(random % 100);
        uint8 r2 = uint8(_random(r1, 12));

        if (!advance_) {
            if (r1 < 90) {
                return r2;
            } else if (r1 < 98) {
                return r2 + 12;
            } else {
                return r2 + 24;
            }
        } else {
            if (r1 < 80) {
                return r2 + 12;
            } else if (r1 < 98) {
                return r2 + 24;
            } else {
                return r2 + 36;
            }
        }
    }

    function randomHeroQuality(uint256 seed_) public view override returns (uint8) {
        return uint8(_random(seed_, 100));
    }

    function getAttributesById(uint256 heroId_) public view override returns (uint256[] memory){
        IHero.Info memory heroInfo = hero().heroInfo(heroId_);
        return getAttributesByInfo(heroInfo);
    }

    function getAttributesByInfo(IHero.Info memory info_) public view override returns (uint256[] memory){
        uint16 level = info_.level;
        uint8 heroType = info_.heroType;
        uint256 rarity = getHeroRarity(heroType);
        //attrs
        uint256 strength = rarity * 10;
        uint256 dexterity = rarity * 10;
        uint256 intelligence = rarity * 10;
        uint256 luck = rarity * 10;

        uint256[] memory attrs = new uint256[](7);
        attrs[0] = level;
        attrs[1] = heroType;
        attrs[2] = rarity;
        attrs[3] = strength;
        attrs[4] = dexterity;
        attrs[5] = intelligence;
        attrs[6] = luck;
        return attrs;
    }

    function getHeroRarity(uint256 heroType_) public pure returns (uint256){
        if (heroType_ < 12) {
            return 1;
        } else if (heroType_ < 24) {
            return 2;
        } else if (heroType_ < 36) {
            return 3;
        } else {
            return 4;
        }
    }

    /**
     * random
     */
    function _random(uint256 seed_, uint256 randomSize_) private view returns (uint256){
        uint256 nonce = seed_;
        uint256 difficulty = block.difficulty;
        uint256 gaslimit = block.gaslimit;
        uint256 number = block.number;
        uint256 timestamp = block.timestamp;
        uint256 gasprice = tx.gasprice;
        uint256 random = uint256(keccak256(abi.encodePacked(nonce, difficulty, gaslimit, number, timestamp, gasprice))) % randomSize_;
        return random;
    }
}
