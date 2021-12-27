// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./../interface/IHeroConfig.sol";

contract HeroConfig is IHeroConfig {

    address public registryAddress;

    constructor(address registry_) public {
        registryAddress = registry_;
    }

    mapping(uint256 => uint256) public override configs;

    function setConfig(uint256 key_, uint256 value_) public returns (uint256){
        configs[key_] = value_;
    }

    function getHeroPrice(bool advance_) public pure override returns (uint256){
        if (advance_) {
            return 20 * 10e18;
        } else {
            return 10 * 10e18;
        }
    }

    function randomHeroType(bool advance_, uint256 random_) public view override returns (uint256){
        uint256 r1 = random_ % 100;
        uint256 r2 = _random(random_, 12);
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