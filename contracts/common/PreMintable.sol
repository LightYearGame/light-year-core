// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract PreMintable {

    // Time the contract was deployed.
    uint256 public timeDeployed;

    // Deployer of the contract.
    address public deployer;

    constructor() public {
        timeDeployed = now;
        deployer = msg.sender;
    }

    // The owner of the contract can mint within the 72 hours.
    // We need this method because we (the dev) did NFT pre-sale.
    // https://medium.com/@lightyear-game/light-year-nft-starter-pack-sale-3cecd1f29ce4
    //
    // Within 72 hours, we will mint the NFTs to a smart contract for buyers
    // of the starter packs to claim from it.
    modifier onlyForPreMint(){
        require(msg.sender == deployer, "Only deployer");
        require(now < timeDeployed + (72 hours), "Only in 72 hours");
        _;
    }
}
