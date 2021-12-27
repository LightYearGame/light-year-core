// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IRegistry {

    function isOperator(address operator_) external view returns (bool);

    function base() external view returns (address);

    function research() external view returns (address);


    function account() external view returns (address);

    function fleets() external view returns (address);

    function explore() external view returns (address);

    function battle() external view returns (address);

    function ship() external view returns (address);

    function hero() external view returns (address);


    function shipConfig() external view returns (address);

    function heroConfig() external view returns (address);

    function fleetsConfig() external view returns (address);

    function exploreConfig() external view returns (address);


    function baseConfig() external view returns (address);

    function researchConfig() external view returns (address);

    function miningConfig() external view returns (address);

    function claimConfig() external view returns (address);

    function uniswapV2Router() external view returns (address);


    function stableToken() external view returns (address);

    function tokenIron() external view returns (address);

    function tokenGold() external view returns (address);

    function tokenEnergy() external view returns (address);

    function tokenSilicate() external view returns (address);

    function tokenLightCoin() external view returns (address);


    function staking() external view returns (address);

    function burning() external view returns (address);
}
