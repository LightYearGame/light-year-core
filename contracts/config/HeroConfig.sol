// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "../interface/IHeroConfig.sol";
import "../interface/IRegistry.sol";
import "../common/Randomness.sol";

contract HeroConfig is IHeroConfig, Randomness {

    address public registryAddress;

    constructor(address registry_) public {
        registryAddress = registry_;
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function getHeroPrice(bool advance_) external pure override returns (uint256){
        if (advance_) {
            return 10000 * 1e18;
        } else {
            return 1000 * 1e18;
        }
    }

    function randomHeroType(bool advance_, uint256 seed_) external view override returns (uint8) {
        uint8 r1 = uint8(getRandomNumber(seed_) % 100);
        uint8 r2 = uint8(getRandomNumber(r1) % 12);

        if (!advance_) {
            if (r1 < 90) {
                return r2;
            } else if (r1 < 98) {
                return r2 + uint8(12);
            } else {
                return r2 + uint8(24);
            }
        } else {
            if (r1 < 80) {
                return r2 + uint8(12);
            } else if (r1 < 98) {
                return r2 + uint8(24);
            } else {
                return r2 + uint8(36);
            }
        }
    }

    function randomHeroTypeRarier(uint8 heroType_, uint256 seed_) external view override returns (uint8) {
        uint8 r = uint8(getRandomNumber(seed_) % 12);
        if (heroType_ < 12) {
          return r + uint8(12);
        } else if (heroType_ < 24) {
          return r + uint8(24);
        } else if (heroType_ < 36) {
          return r + uint8(36);
        } else {
          return heroType_;
        }
    }

    function randomHeroQuality(uint256 seed_) external view override returns (uint8) {
        return uint8(getRandomNumber(seed_) % 100 + 1);
    }
}
