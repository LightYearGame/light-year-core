// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IRegistry.sol";

contract Registry is Ownable, IRegistry {

    mapping(address => bool) private operatorMap;

    address public override base;
    address public override research;

    address public override fleets;
    address public override account;
    address public override battle;
    address public override explore;

    address public override ship;
    address public override hero;

    address public override shipConfig;
    address public override heroConfig;
    address public override fleetsConfig;
    address public override exploreConfig;

    address public override stableToken;  // WBNB is the best choice.

    address public override baseConfig;
    address public override researchConfig;
    address public override miningConfig;
    address public override claimConfig;

    address public override uniswapV2Router;

    address public override tokenIron;
    address public override tokenGold;
    address public override tokenEnergy;
    address public override tokenSilicate;

    address public override tokenLightCoin;

    address public override staking;
    address public override burning;

    constructor() public {
        setOperator(_msgSender());
    }

    function isOperator(address operator_) public override view returns (bool){
        return operatorMap[operator_];
    }

    function setOperator(address operator_) public onlyOwner {
        operatorMap[operator_] = true;
    }

    function setBase(address base_) external onlyOwner {
        base = base_;
        setOperator(base_);
    }

    function setResearch(address research_) external onlyOwner {
        research = research_;
        setOperator(research_);
    }

    function setFleets(address addr_) public onlyOwner {
        fleets = addr_;
        setOperator(fleets);
    }

    function setAccount(address addr_) public onlyOwner {
        account = addr_;
        setOperator(explore);
    }

    function setExplore(address addr_) public onlyOwner {
        explore = addr_;
        setOperator(explore);
    }

    function setBattle(address addr_) public onlyOwner {
        battle = addr_;
        setOperator(battle);
    }

    function setShip(address addr_) public onlyOwner {
        ship = addr_;
        setOperator(ship);
    }

    function setHero(address addr_) public onlyOwner {
        hero = addr_;
        setOperator(hero);
    }

    function setShipConfig(address addr_) public onlyOwner {
        shipConfig = addr_;
    }

    function setHeroConfig(address addr_) public onlyOwner {
        heroConfig = addr_;
    }

    function setFleetsConfig(address addr_) public onlyOwner {
        fleetsConfig = addr_;
    }

    function setExploreConfig(address addr_) public onlyOwner {
        exploreConfig = addr_;
    }

    function setStableToken(address stableToken_) public onlyOwner {
        stableToken = stableToken_;
    }

    function setBaseConfig(address baseConfig_) external onlyOwner {
        baseConfig = baseConfig_;
    }

    function setResearchConfig(address researchConfig_) external onlyOwner {
        researchConfig = researchConfig_;
    }

    function setMiningConfig(address miningConfig_) external onlyOwner {
        miningConfig = miningConfig_;
    }

    function setClaimConfig(address claimConfig_) external onlyOwner {
        claimConfig = claimConfig_;
    }

    function setUniswapV2Router(address router_) external onlyOwner {
        uniswapV2Router = router_;
    }

    function setTokenIron(address tokenIron_) external onlyOwner {
        tokenIron = tokenIron_;
    }

    function setTokenGold(address tokenGold_) external onlyOwner {
        tokenGold = tokenGold_;
    }

    function setTokenEnergy(address tokenEnergy_) external onlyOwner {
        tokenEnergy = tokenEnergy_;
    }

    function setTokenSilicate(address tokenSilicate_) external onlyOwner {
        tokenSilicate = tokenSilicate_;
    }

    function setTokenLightCoin(address tokenLightCoin_) external onlyOwner {
        tokenLightCoin = tokenLightCoin_;
    }


    function setStaking(address staking_) external onlyOwner {
        staking = staking_;
        setOperator(staking);
    }

    function setBurning(address burning_) external onlyOwner {
        burning = burning_;
        setOperator(hero);
    }
}