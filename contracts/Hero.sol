// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "./token/Nft.sol";
import "./interface/IRegistry.sol";
import "./interface/IHero.sol";
import "./interface/IHeroConfig.sol";
import "./interface/ICommodityERC20.sol";

contract Hero is Nft, IHero {

    //const
    string constant public TOKEN_NAME = "LightYearHero";
    string constant public TOKEN_SYMBOL = "LYH";
    string constant public TOKEN_BASE_URI = "https://lightyear.game/hero/";

    //token id to hero
    mapping(uint256 => Info) public heroInfoMap;

    //registry
    address public registryAddress;

    //only operator
    modifier onlyOperator(){
        require(registry().isOperator(msg.sender), "onlyOperator: require operator.");
        _;
    }

    event DrawHeroResult(uint256[] heroIdArray);

    /**
     * constructor
     */
    constructor(address registry_) public Nft(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_BASE_URI) {
        registryAddress = registry_;
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function heroConfig() private view returns (IHeroConfig){
        return IHeroConfig(registry().heroConfig());
    }

    function tokenLightCoin() private view returns (ICommodityERC20){
        return ICommodityERC20(registry().tokenLightCoin());
    }

    function setBaseURI(string memory baseURI_) external {
        _setBaseURI(baseURI_);
    }

    function operatorTransfer(address from_, address to_, uint256 tokenId_) external override onlyOperator {
        _transfer(from_, to_, tokenId_);
    }

    function heroInfo(uint256 heroId_) public override view returns (Info memory){
        return heroInfoMap[heroId_];
    }

    function multipleDrawHero(uint256 amount_, bool advance_) public payable {

        //base price
        uint256 basePrice = heroConfig().getHeroPrice(advance_);
        uint256 totalPrice = amount_ * basePrice;

        //pay light year coin
        tokenLightCoin().burn(totalPrice);

        //mint
        uint256[] memory heroIdArray = new uint256[](amount_);
        for (uint i = 0; i < amount_; i++) {
            uint256 tokenId = _mintHero(_msgSender(), advance_);
            heroIdArray[i] = tokenId;
        }

        //event
        emit DrawHeroResult(heroIdArray);
    }

    /**
     * mint hero
     */
    function _mintHero(address addr_, bool advance_) private returns (uint256){

        //mint nft
        uint256 tokenId = _mintNft(addr_);

        //create hero
        Info memory info = _createHero(advance_);
        heroInfoMap[tokenId] = info;

        return tokenId;
    }

    /**
     *
     */
    function _createHero(bool advance_) private view returns (Info memory){
        uint8 heroType = uint8(_randomHeroType(advance_));
        Info memory info = Info(1, heroType);
        return info;
    }

    function _randomHeroType(bool advance_) private view returns (uint256){
        uint256 random = _random(1e18);
        uint256 heroType = heroConfig().randomHeroType(advance_, random);
        return heroType;
    }

    /**
     * 
     */
    function _burnHero(uint256 tokenId_) private {

        //burn nft
        _burnNft(tokenId_);

        //burn hero
        delete heroInfoMap[tokenId_];
    }

    /**
     *
     */
    function upgradeHero(uint256 heroId_) external override onlyOperator {
        Info storage hero = heroInfoMap[heroId_];
        hero.level++;
    }

    /**
     * random
     */
    function _random(uint256 randomSize_) private view returns (uint256){
        uint256 nonce = totalSupply();
        uint256 difficulty = block.difficulty;
        uint256 gaslimit = block.gaslimit;
        uint256 number = block.number;
        uint256 timestamp = block.timestamp;
        uint256 gasprice = tx.gasprice;
        uint256 random = uint256(keccak256(abi.encodePacked(nonce, difficulty, gaslimit, number, timestamp, gasprice))) % randomSize_;
        return random;
    }

}