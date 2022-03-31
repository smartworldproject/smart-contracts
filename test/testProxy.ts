// test/Box.proxy.js

import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";
import {DeployFunction} from "@openzeppelin/hardhat-upgrades/dist/deploy-proxy";
import {ethers, upgrades} from "hardhat";
import {Contract} from "hardhat/internal/hardhat-network/stack-traces/model";
import {STT, STTS, STTS__factory, STT__factory} from "../typechain";

// Load dependencies
const {expect} = require("chai");

// Start test block
describe("With (proxy)", () => {
  let STT: STT;
  let STTS: STTS;
  let addrs: SignerWithAddress[],
    owner: SignerWithAddress,
    addr1: SignerWithAddress,
    addr2: SignerWithAddress,
    addr3: SignerWithAddress;

  beforeEach(async function () {
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    const STTSFactory = (await ethers.getContractFactory("STTS", owner)) as STTS__factory;
    const STTFactory = (await ethers.getContractFactory("STT", owner)) as STT__factory;

    STTS = await STTSFactory.deploy();
    await STTS.deployed();
    STT = (await upgrades.deployProxy(STTFactory, [addr1.address, addr2.address, STTS.address], {
      initializer: "initialize",
    })) as STT;
    await STT.deployed();
  });

  // Test case
  it("retrieve returns a value previously initialized", async function () {
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect(await STTS.symbol()).to.equal("STTS");
    expect(await STT.symbol()).to.equal("STT");
    expect(await STT.owners(owner.address)).to.equal(true);
    expect(await STT.owners(addr1.address)).to.equal(true);
    expect(await STT.owners(addr2.address)).to.equal(true);
    expect(await STT.owners(addrs[3].address)).to.equal(false);
  });
  it("should pass owner role", async () => {
    await STT.replaceOwner(addr3.address, addr1.address);
    expect(await STT.elected(addr3.address)).to.equal(false);
    console.log(await STT.election(addr3.address));
    await STT.connect(addr1).replaceOwner(addr3.address, addr1.address);
    await STT.connect(addr2).replaceOwner(addr3.address, addr1.address);
    const newOwner = await STT.owners(addr3.address);
    expect(newOwner).to.equal(true);
  });
});
