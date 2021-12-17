// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract Nft is ERC721 {

    using Counters for Counters.Counter;

    //token id owner
    mapping(uint256 => address) private _tokenIdOwnerMap;

    //owner token amount
    mapping(address => uint256) private _ownerTokenAmountMap;

    //owner token list
    mapping(address => uint256[]) private _ownerTokenListMap;

    //token id tracker
    Counters.Counter private _tokenIdTracker;

    //constructor
    constructor(string memory name, string memory symbol, string memory baseURI) public ERC721(name, symbol) {
        _setBaseURI(baseURI);
    }

    //mint nft
    function _mintNft(address addr_) internal returns (uint256){
        uint256 tokenId = _tokenIdTracker.current() + 1;
        _mint(addr_, tokenId);
        _tokenIdTracker.increment();
        return tokenId;
    }

    //burn nft
    function _burnNft(uint256 tokenId) internal {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "The caller is not owner nor approved.");
        _burn(tokenId);
    }
    
}