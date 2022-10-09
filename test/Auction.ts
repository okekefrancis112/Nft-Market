import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";


describe("Auction", function () {
  async function deployOneYearLockFixture() {

    console.log("OBTAINING SIGNERS");
    
    const [owner, otherAccount] = await ethers.getSigners();

    console.log("DEPLOYING TOKEN");
    
    const Token = await ethers.getContractFactory("Lock");
    const token = await Token.deploy();
    await token.deployed();

    console.log("DEPLOYING NFT");

    const NFT = await ethers.getContractFactory("UnicornNFT");
    const nft = await NFT.deploy();
    await nft.deployed();


    console.log("MINTING NFT TO USER ADDRESS");

    const Mint = await nft.safeMint(owner.address, "developeruche.com");
    await Mint.wait();
    

    return { token, nft, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { token } = await loadFixture(deployOneYearLockFixture);

    });
  });

});
