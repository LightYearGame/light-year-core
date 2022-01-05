// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "../interface/IRegistry.sol";
import "../interface/IHero.sol";
import "../interface/IHeroConfig.sol";
import "../interface/ILightCoin.sol";

contract Hero is ERC721, IHero {

    using SafeERC20 for ILightCoin;

    string constant public TOKEN_NAME = "LightYearHero";
    string constant public TOKEN_SYMBOL = "LYH";
    string constant public TOKEN_BASE_URI = "https://lightyear.game/hero/";

    // Token id to hero info
    mapping(uint256 => Info) private _heroInfoMap;

    // Registry
    address public registryAddress;

    // Next token id.
    uint256 public nextTokenId = 1;

    // Only operator
    modifier onlyOperator(){
        require(registry().isOperator(msg.sender), "onlyOperator: require operator.");
        _;
    }

    event DrawHeroResult(uint256[] heroIdArray);

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

    function setBaseURI(string memory baseURI_) external {
        _setBaseURI(baseURI_);
    }

    function operatorTransfer(address from_, address to_, uint256 tokenId_) external override onlyOperator {
        _transfer(from_, to_, tokenId_);
    }

    function heroInfo(uint256 heroId_) external override view returns (Info memory){
        return _heroInfoMap[heroId_];
    }

    function multipleDrawHero(uint256 amount_, bool advance_) external payable {

        //base price
        uint256 basePrice = heroConfig().getHeroPrice(advance_);
        uint256 totalPrice = amount_ * basePrice;

        //pay light year coin
        tokenLightCoin().safeTransferFrom(msg.sender, address(this), totalPrice);
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

        // Mint nft
        uint256 tokenId = nextTokenId;
        ++nextTokenId;

        _mint(addr_, tokenId);

        // Fill hero info.
        _heroInfoMap[tokenId] = Info({
          level: 1,
          quality: _randomHeroQuality(totalSupply()),
          heroType: _randomHeroType(advance_, totalSupply() + 1)
        });

        return tokenId;
    }

    function _randomHeroType(bool advance_, uint256 seed_) private view returns (uint8) {
        return heroConfig().randomHeroType(advance_, seed_);
    }

    function _randomHeroQuality(uint256 seed_) private view returns (uint8) {
        return heroConfig().randomHeroQuality(seed_);
    }

    /**
     *
     */
    function upgradeHero(uint256 heroId_) external override onlyOperator {
        Info storage hero = _heroInfoMap[heroId_];
	++hero.level;
    }
}
