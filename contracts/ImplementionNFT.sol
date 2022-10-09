// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./utils/ERC721URIStorage.sol";
import "./libraries/Counters.sol";





/// @title This nft contract would be deployed any time the users creates a collection. (this contract must implement Minimal proxy)
contract UnicornUsersNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _myCounter;
    uint256 MAX_SUPPLY = 50;
    bool initailized;


    error NotInitialized();
    error AlreadyIntialized();


    /**
     * ===================================================
     * ----------------- MODIFIERS -----------------------
     * ===================================================
     */

    modifier isInitialized() {
        if(!initailized) {
            revert NotInitialized();
        }
        _;
    }

    /**
     * ===================================================
     * ----------------- INITIALIZER --------------------
     * ===================================================
     */

    function initailize(string memory name_, string memory symbol_) public {
        if(initailized) {
            revert AlreadyIntialized();
        }
        _name = name_;
        _symbol = symbol_;
    }


    function safeMint(address to, string memory uri) public isInitialized {
        uint256 tokenId = _myCounter.current();
        require(tokenId <= MAX_SUPPLY, "Sorry, all NFTs have been minted!");
        _myCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
}

