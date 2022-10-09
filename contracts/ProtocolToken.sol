// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

  import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

    /// @title This is a swap contract for the NFT Market
    /// @author team unicorn

  contract UnicornToken is ERC20 {

      // total supply of Unicorn token is 100,000,000
      uint256 constant initialSupply = 100000000 * (10 ** 18);

      // mint the tokens
      constructor() ERC20("Unicorn Token", "UNC") {
          _mint(msg.sender, initialSupply);
      }

  }