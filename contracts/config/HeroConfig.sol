// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./../interface/IHeroConfig.sol";
import "./../interface/IRegistry.sol";

contract HeroConfig is IHeroConfig {

    address public registryAddress;

    constructor(address registry_) public {
        registryAddress = registry_;
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
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
        return uint8(_random(seed_, 100) + 1);
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
