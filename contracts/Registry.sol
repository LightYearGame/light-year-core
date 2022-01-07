// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IRegistry.sol";

contract Registry is Ownable, IRegistry {

    mapping(address => bool) private operatorMap;

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

    constructor() public {
        setOperator(_msgSender());
    }

    function isOperator(address operator_) public override view returns (bool){
        return operatorMap[operator_];
    }

    function setOperator(address operator_) public onlyOwner {
        operatorMap[operator_] = true;
    }

    // base and research
    function setBase(address base_) external onlyOwner {base = base_; setOperator(base_);}
    function setResearch(address research_) external onlyOwner {research = research_; setOperator(research_);}

    // fleets and ships
    function setFleets(address addr_) public onlyOwner {fleets = addr_; setOperator(fleets);}
    function setAccount(address addr_) public onlyOwner {account = addr_; setOperator(account);}
    function setExplore(address addr_) public onlyOwner {explore = addr_; setOperator(explore);}
    function setBattle(address addr_) public onlyOwner {battle = addr_; setOperator(battle);}
    function setShip(address addr_) public onlyOwner {ship = addr_; setOperator(ship);}
    function setHero(address addr_) public onlyOwner {hero = addr_; setOperator(hero);}

    // staking and burning
    function setStaking(address addr_) external onlyOwner {staking = addr_; setOperator(addr_);}
    function setBurning(address addr_) external onlyOwner {burning = addr_; setOperator(addr_);}
    function setUniswapV2Router(address addr_) external onlyOwner {uniswapV2Router = addr_;}
    function setStableToken(address addr_) external onlyOwner {stableToken = addr_;}

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

}