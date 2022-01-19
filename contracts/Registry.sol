// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IRegistry.sol";

// Registry will be managed by timelock and a governance contract.
contract Registry is Ownable, IRegistry {

    // base and research
    address public override base;
    address public override research;

    // fleets and ships
    address public override fleets;
    address public override account;
    address public override battle;
    address public override explore;
    address public override ship;
    address public override hero;

    // staking and burning
    address public override staking;
    address public override burning;
    address public override uniswapV2Router;
    address public override stableToken;  // WBNB is the best choice.
    address public override treasury;

    // fleets config and ships config
    address public override shipConfig;
    address public override heroConfig;
    address public override fleetsConfig;
    address public override exploreConfig;
    address public override battleConfig;
    address public override shipAttrConfig;
    address public override heroAttrConfig;

    // base config and research config
    address public override baseConfig;
    address public override researchConfig;
    address public override miningConfig;
    address public override claimConfig;

    // tokens
    address public override tokenIron;
    address public override tokenGold;
    address public override tokenEnergy;
    address public override tokenSilicate;
    address public override tokenLightCoin;

    // access
    mapping(address => bool) public override canMintCommodity;

    constructor() public {}

    // base and research
    function setBase(address base_) external onlyOwner {base = base_;}
    function setResearch(address research_) external onlyOwner {research = research_;}

    // fleets and ships
    function setFleets(address addr_) public onlyOwner {fleets = addr_;}
    function setAccount(address addr_) public onlyOwner {account = addr_;}
    function setExplore(address addr_) public onlyOwner {explore = addr_;}
    function setBattle(address addr_) public onlyOwner {battle = addr_;}
    function setShip(address addr_) public onlyOwner {ship = addr_;}
    function setHero(address addr_) public onlyOwner {hero = addr_;}

    // staking and burning
    function setStaking(address addr_) external onlyOwner {staking = addr_;}
    function setBurning(address addr_) external onlyOwner {burning = addr_;}
    function setUniswapV2Router(address addr_) external onlyOwner {uniswapV2Router = addr_;}
    function setStableToken(address addr_) external onlyOwner {stableToken = addr_;}
    function setTreasury(address addr_) external onlyOwner {treasury = addr_;}

    // fleets config and ships config
    function setShipConfig(address addr_) external onlyOwner {shipConfig = addr_;}
    function setHeroConfig(address addr_) external onlyOwner {heroConfig = addr_;}
    function setFleetsConfig(address addr_) external onlyOwner {fleetsConfig = addr_;}
    function setExploreConfig(address addr_) external onlyOwner {exploreConfig = addr_;}
    function setBattleConfig(address addr_) external onlyOwner {battleConfig = addr_;}
    function setShipAttrConfig(address addr_) external onlyOwner {shipAttrConfig = addr_;}
    function setHeroAttrConfig(address addr_) external onlyOwner {heroAttrConfig = addr_;}

    // base config and research config
    function setBaseConfig(address addr_) external onlyOwner {baseConfig = addr_;}
    function setResearchConfig(address addr_) external onlyOwner {researchConfig = addr_;}
    function setMiningConfig(address addr_) external onlyOwner {miningConfig = addr_;}
    function setClaimConfig(address addr_) external onlyOwner {claimConfig = addr_;}

    // tokens
    function setTokenIron(address addr_) external onlyOwner {tokenIron = addr_;}
    function setTokenGold(address addr_) external onlyOwner {tokenGold = addr_;}
    function setTokenEnergy(address addr_) external onlyOwner {tokenEnergy = addr_;}
    function setTokenSilicate(address addr_) external onlyOwner {tokenSilicate = addr_;}
    function setTokenLightCoin(address addr_) external onlyOwner {tokenLightCoin = addr_;}

    // access
    function setCanMintCommodity(address addr_, bool value_) external onlyOwner {
        canMintCommodity[addr_] = value_;
    }
}
