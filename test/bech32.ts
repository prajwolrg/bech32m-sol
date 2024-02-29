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

  describe("Validation", function () {
    it("Should validate valid address", async function () {
      const { bech32m } = await loadFixture(deployBech32M);
      
      expect(await bech32m.validateAleoAddr("aleo1g2vt2rag4fzug6aklxxxhhraza54gw0jr9q6myjtkm3jjmdtugqq6yrng8")).to.equal(true);
      expect(await bech32m.validateAleoAddr("aleo15yaapw723t9m945xaxadhane5ghydagkdmk9hzgrs3n6zcphzv9qcqpnzk")).to.equal(true);
      expect(await bech32m.validateAleoAddr("aleo1f2ndcsfkg9tftuzk9j83f6etrum9ruaa585f6fn2yyl4wcqu0yqsad0fvk")).to.equal(true);
      expect(await bech32m.validateAleoAddr("aleo1lr5rjkpucudys4nfj32sp3ykx0nsj3mem2wr3fje75rr6vxeug8q9wauqh")).to.equal(true);
      expect(await bech32m.validateAleoAddr("aleo1xgnhgw48k0arjsksaeqv5zw6d497hfe99zp8pw4na397hdhpm5zsfh850h")).to.equal(true);
    });

    it("Should revert on invalid length", async () => {
      const { bech32m } = await loadFixture(deployBech32M);
      const invalidLengthMessage = "Invalid Aleo address length"
      await expect(bech32m.validateAleoAddr("aleo1xgnhgw48k0arjsksaeqv5zw6d497hfe99zp8pw4na397hdhpm5zsfh850")).to.be.revertedWith(invalidLengthMessage)
    })

    it("Should revert on valid character at in invalid location", async () => {
      const { bech32m } = await loadFixture(deployBech32M);
      const invalidChecksumMessage = "Invalid checksum"
      await expect(bech32m.validateAleoAddr("aleo1xgnagw48k0arjsksaeqv5zw6d497hfe99zp8pw4na397hdhpm5zsfh850h")).to.be.revertedWith(invalidChecksumMessage)
      // Replace h with a here ----------------------^

      await expect(bech32m.validateAleoAddr("aleo1xgnhgw48k0arjsksaeqv5zw6d497hfe99zp8pw4na397hdhpm5zsfh850a")).to.be.revertedWith(invalidChecksumMessage)
      // Replace h with a here ----------------------------------------------------------------------------^

      await expect(bech32m.validateAleoAddr("aleo1xgnhgw48k1arjsksaeqv5zw6d497hfe99zp8pw4na397hdhpm5zsfh850a")).to.be.revertedWith(invalidChecksumMessage)
      // Replace 0 with 1 here ----------------------------^
    })

    it("Should revert on invalid character", async () => {
      const { bech32m } = await loadFixture(deployBech32M);
      const invalidChecksumMessage = "Invalid checksum"

      await expect(bech32m.validateAleoAddr("aleo1xgnhgw48k0arjsksaeqv5zw6d497hfe99zp8pw4na397hdhpm5zsfh8507")).to.be.revertedWith(invalidChecksumMessage)
      // Replace h with 7 here ----------------------------------------------------------------------------^

      await expect(bech32m.validateAleoAddr("aleo1lr5rjkpucudys4nfj32sp3ykx9nsj3mem2wr3fje75rr6vxeug8q9wauqh")).to.be.revertedWith(invalidChecksumMessage)
      // Replace 0 with 9 here --------------------------------------------^
    })

  });
});