import {ethers} from "hardhat";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";
import chai from "chai";
import chaiAsPromised from "chai-as-promised";
import {STTS__factory, STTS} from "../typechain";
import {INITIAL_VALUE} from "./helpers";

chai.use(chaiAsPromised);
const {expect} = chai;

describe("STTS", () => {
  let STTS: STTS;
  let addrs: SignerWithAddress[],
    owner: SignerWithAddress,
    addr1: SignerWithAddress,
    addr2: SignerWithAddress;

  beforeEach(async () => {
    // 1
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    // 2
    const STTSTokenFactory = (await ethers.getContractFactory("STTS", owner)) as STTS__factory;
    STTS = await STTSTokenFactory.deploy();
    const initialSupply = await STTS.totalSupply();
    // 3
    expect(initialSupply).to.eq(INITIAL_VALUE);
    expect(STTS.address).to.properAddress;
  });

  // 4
  describe("Names and Symbol and Owner and Cap", async () => {
    it("should be Smart Token Stock", async () => {
      let name = await STTS.name();
      expect(name).to.eq("Smart Token Stock");
    });
    it("Should be STTS", async () => {
      let symbol = await STTS.symbol();
      expect(symbol).to.eq("STTS");
    });
    it("Should be Capable", async () => {
      let userBalance = await STTS.balanceOf(owner.address);
      expect(userBalance).to.eq(INITIAL_VALUE);
    });
  });
  describe("Transfer STTS", async () => {
    // 5
    it("should fail due to mint address not have token", () =>
      expect(STTS.connect(addr2).transfer(addr1.address, 10)).to.eventually.be.rejectedWith(
        Error,
        "transfer amount exceeds balance"
      ));

    it("should transfer 100 STTS to another", async () => {
      await STTS.transfer(addr2.address, INITIAL_VALUE);
      const balanceOfOwner = await STTS.balanceOf(owner.address);
      const balanceOfAddr2 = await STTS.balanceOf(addr2.address);
      expect(balanceOfOwner).to.eq(0);
      expect(balanceOfAddr2).to.eq(INITIAL_VALUE);
    });
  });
});
