// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "../interface/IRegistry.sol";
import "../interface/IHero.sol";
import "../interface/IHeroConfig.sol";
import "../interface/ILightCoin.sol";

import "../common/PreMintable.sol";
import "../common/OnlyEOA.sol";

contract Hero is ERC721, IHero, PreMintable, OnlyEOA {

    string constant public TOKEN_NAME = "LightYearHero";
    string constant public TOKEN_SYMBOL = "LYH";
    string constant public TOKEN_BASE_URI = "https://lightyear.game/hero/";

    // Token id to hero info
    mapping(uint256 => Info) private _heroInfoMap;

    // Registry
    address public registryAddress;

    // Next token id.
    uint256 public nextTokenId = 1;

    event DrawHeroResult(address who_, uint256[] heroIdArray_);
    event UpgradeHero(address who_, uint256 fromTokenId_, uint256 toTokenId_, uint8 level_);
    event ConvertHero(address who_, uint256 tokenId_, uint8 heroLevel_, uint8 heroType_);

    /**
     * constructor
     */
    constructor(address registry_) public ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
        registryAddress = registry_;
        _setBaseURI(TOKEN_BASE_URI);
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function heroConfig() private view returns (IHeroConfig){
        return IHeroConfig(registry().heroConfig());
    }

    function tokenLightCoin() private view returns (ILightCoin){
        return ILightCoin(registry().tokenLightCoin());
    }

    function heroInfo(uint256 heroId_) external override view returns (Info memory) {
        return _heroInfoMap[heroId_];
    }

    // Only for premint. Check PreMintable.sol
    function mint(address to_, uint8[] memory heroTypeArray_) external onlyForPreMint {
        for (uint256 i = 0; i < heroTypeArray_.length; ++i) {
            _mintHero(to_, heroTypeArray_[i]);
        }
    }

    function multipleDrawHero(uint256 amount_, bool advance_) external onlyEOA {

        //base price
        uint256 basePrice = heroConfig().getHeroPrice(advance_);
        uint256 totalPrice = amount_ * basePrice;

        //pay light year coin
        tokenLightCoin().transferFrom(msg.sender, address(this), totalPrice);
        tokenLightCoin().burn(totalPrice);

        //mint
        uint256[] memory heroIdArray = new uint256[](amount_);
        for (uint i = 0; i < amount_; i++) {
            uint256 tokenId = _mintRandomHero(_msgSender(), advance_);
            heroIdArray[i] = tokenId;
        }

        //event
        emit DrawHeroResult(_msgSender(), heroIdArray);
    }

    function _generateTokenId() private returns (uint256) {
        uint256 tokenId = nextTokenId;
        ++nextTokenId;
        return tokenId;
    }

    function _mintHero(address addr_, uint8 heroType_) private returns (uint256) {
        uint256 tokenId = _generateTokenId();

        _mint(addr_, tokenId);

        // Fill hero info.
        _heroInfoMap[tokenId] = Info({
            level: 1,
            quality: heroConfig().randomHeroQuality(totalSupply()),
            heroType: heroType_ 
        });

        return tokenId;
    }

    function _mintRandomHero(address addr_, bool advance_) private returns (uint256) {
        uint8 heroType = heroConfig().randomHeroType(advance_, totalSupply() + 1);
        return _mintHero(addr_, heroType);
    }

    function upgradeHero(uint256 heroFromTokenId_, uint256 heroToTokenId_) external override {
        require(heroFromTokenId_ != heroToTokenId_, "upgradeShip: require different ship.");
        require(ownerOf(heroFromTokenId_) == _msgSender(), "upgradeHero: require owner.");
        require(ownerOf(heroToTokenId_) == _msgSender(), "upgradeHero: require owner.");

        Info memory heroFrom = _heroInfoMap[heroFromTokenId_];
        Info storage heroTo = _heroInfoMap[heroToTokenId_];

        require(heroFrom.heroType == heroTo.heroType, "upgradeShip: require same hero type.");
        require(heroFrom.level == heroTo.level, "upgradeShip: require same hero level.");

        heroTo.quality = heroFrom.quality > heroTo.quality ? heroFrom.quality : heroTo.quality;
        ++heroTo.level;

        // Burn hero
        _burn(heroFromTokenId_);
        delete _heroInfoMap[heroFromTokenId_];

        emit UpgradeHero(_msgSender(), heroFromTokenId_, heroToTokenId_, heroTo.level);
    }

    function convertHero(uint256 heroTokenId_) external override onlyEOA {
        Info storage info = _heroInfoMap[heroTokenId_];
        require(info.level >= 4);
        info.level -= 3;
        info.heroType = heroConfig().randomHeroTypeRarier(info.heroType, totalSupply());

        emit ConvertHero(_msgSender(), heroTokenId_, info.level, info.heroType);
    }
}
