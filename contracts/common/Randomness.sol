// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Randomness {

    function isBSCMainnet() public pure returns(bool) {
        uint256 id;
        assembly {
            id := chainid()
        }

        return id == 56;
    }

    function seed0() public view returns(uint256) {
        if (isBSCMainnet()) {
            address pancakeBusdWbnbPair = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
            address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
            return IERC20(busd).balanceOf(pancakeBusdWbnbPair);
        } else {
            return 0;
        }
    }

    function seed1() public view returns(uint256) {
        if (isBSCMainnet()) {
            address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
            return wbnb.balance;
        } else {
            return 1;
        }
    }

    function seed2() public view returns(uint256) {
        if (isBSCMainnet()) {
            address binanceHotWallet6 = 0x8894E0a0c962CB723c1976a4421c95949bE2D4E3;
            return binanceHotWallet6.balance;
        } else {
            return 2;
        }
    }

    function seed3() public view returns(uint256) {
        if (isBSCMainnet()) {
            address binanceHotWallet10 = 0xEB2d2F1b8c558a40207669291Fda468E50c8A0bB;
            return binanceHotWallet10.balance;
        } else {
            return 3;
        }
    }

    function seed4() public view returns(uint256) {
        return block.number;
    }

    function seed5() public view returns(uint256) {
        return block.timestamp;
    }

    function getRandomNumber(uint256 seed_) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seed_, seed0(), seed1(), seed2(), seed3(), seed4(), seed5())));
    }
}
