// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";




/// @title This is the protocol NFT the contract would be user to mint the inital NFT on the Marketplace. (the marketplace would have approval on all this NFT by default)
contract UnicornNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _myCounter;
    uint256 MAX_SUPPLY = 50;

    constructor() ERC721("Unicorn Marketplace NFT", "UMN") {}


    /// @dev this nft can be minted by any user to the total supply is reached
    function safeMint(address to, string memory uri) public{
        uint256 tokenId = _myCounter.current();
        require(tokenId <= MAX_SUPPLY, "Sorry, all NFTs have been minted!");
        _myCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
}
