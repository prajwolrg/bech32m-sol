import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("bech32m", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployBech32M() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Bech32M = await ethers.getContractFactory("bech32m");
    const bech32m = await Bech32M.deploy();

    return { bech32m, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should validate the right address", async function () {
      const { bech32m } = await loadFixture(deployBech32M);
      
      expect(await bech32m.validateAleoAddr("aleo1g2vt2rag4fzug6aklxxxhhraza54gw0jr9q6myjtkm3jjmdtugqq6yrng8")).to.equal(true);
    });
  });
});