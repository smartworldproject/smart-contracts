import {ethers, network} from "hardhat";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";
import chai from "chai";
import chaiAsPromised from "chai-as-promised";
import {STT__factory, STTS__factory, STT, STTS} from "../typechain";
import {RANDOM_ADDRESS} from "./helpers";

chai.use(chaiAsPromised);
const {expect} = chai;

describe("STT", () => {
  let STTS: STTS;
  let STT: STT;
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
    const initialSupply = await STT.totalSupply();
    // 3
    expect(initialSupply).to.eq(0);
    expect(STTS.address).to.properAddress;
    expect(STT.address).to.properAddress;
  });
  // 4
  describe("STT Owners", async () => {
    it("wrong address Shouldn't be equal to Owner", async () => {
      let owner_ = await STT.owners(addr3.address);
      expect(owner_).to.eq(false);
    });
    it("Owner Should be equal to first signer", async () => {
      let owner_ = await STT.owners(owner.address);
      expect(owner_).to.eq(true);
    });
    it("Second Owner Should be equal to second signer", async () => {
      let owner_ = await STT.owners(addr1.address);
      expect(owner_).to.eq(true);
    });
    it("Third Owner Should be equal to third signer", async () => {
      let owner_ = await STT.owners(addr2.address);
      expect(owner_).to.eq(true);
    });
  });

  describe("Change Owner", async () => {
    // 5
    it("Should fail due to caller is not the owner", () =>
      expect(
        STT.connect(addrs[0]).replaceOwner(addr3.address, addr1.address)
      ).to.eventually.be.rejectedWith(Error, "Only from owners!"));

    it("Should Replace Owner role to another", async () => {
      await STT.connect(owner).replaceOwner(addr3.address, addr1.address);
      await STT.connect(addr1).replaceOwner(addr3.address, addr1.address);
      await STT.connect(addr2).replaceOwner(addr3.address, addr1.address);
      let newOwner = await STT.owners(addr3.address);
      expect(newOwner).to.eq(true);
    });
  });

  describe("Authorize Contract", async () => {
    // 5
    it("Should fail due to caller is not the owner", () =>
      expect(STT.connect(addrs[6]).authorizeContract(RANDOM_ADDRESS)).to.eventually.be.rejectedWith(
        Error,
        "Only from owners!"
      ));

    it("Should fail due to caller is already voted", async () => {
      await STT.authorizeContract(RANDOM_ADDRESS);
      expect(STT.authorizeContract(RANDOM_ADDRESS)).to.eventually.be.rejectedWith(
        Error,
        "You already vote for this nominate!"
      );
    });

    it("Shouldn't Authorize contract after 2 minutes", async () => {
      await STT.authorizeContract(RANDOM_ADDRESS);
      await STT.connect(addr1).authorizeContract(RANDOM_ADDRESS);
      await network.provider.send("evm_increaseTime", [120]);
      await network.provider.send("evm_mine");
      const election = await STT.election(RANDOM_ADDRESS);
      expect(election.counter).to.eq(2);
      await STT.connect(addr2).authorizeContract(RANDOM_ADDRESS);
      const isAuthorized = await STT.elected(RANDOM_ADDRESS);
      expect(isAuthorized).to.eq(false);
    });

    it("Should Authorize contract", async () => {
      await STT.authorizeContract(addr3.address);
      await STT.connect(addr1).authorizeContract(addr3.address);
      const election = await STT.election(addr3.address);
      expect(election.counter).to.eq(2);
      await STT.connect(addr2).authorizeContract(addr3.address);
      const isAuthorized = await STT.elected(addr3.address);
      expect(isAuthorized).to.eq(true);
    });
  });
});

describe("STT Trx trade system", () => {
  let STTS: STTS;
  let STT: STT;
  let addrs: SignerWithAddress[],
    owner: SignerWithAddress,
    addr1: SignerWithAddress,
    addr2: SignerWithAddress,
    addr3: SignerWithAddress;

  before(async function () {
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    const STTSFactory = (await ethers.getContractFactory("STTS", owner)) as STTS__factory;
    const STTFactory = (await ethers.getContractFactory("STT", owner)) as STT__factory;

    STTS = await STTSFactory.deploy();
    await STTS.deployed();
    STT = (await upgrades.deployProxy(STTFactory, [addr1.address, addr2.address, STTS.address], {
      initializer: "initialize",
    })) as STT;
    await STT.deployed();
    const initialSupply = await STT.totalSupply();
    // 3
    expect(initialSupply).to.eq(0);
    expect(STTS.address).to.properAddress;
    expect(STT.address).to.properAddress;
    await STT.authorizeContract(addrs[15].address);
    await STT.connect(addr1).authorizeContract(addrs[15].address);
    await STT.connect(addr2).authorizeContract(addrs[15].address);
    const isAuthorized = await STT.elected(addrs[15].address);
    expect(isAuthorized).to.eq(true);
  });

  it("should pass owner role", async () => {
    await STT.replaceOwner(addr3.address, addr1.address);
    expect(await STT.elected(addr3.address)).to.equal(false);
    await STT.connect(addr1).replaceOwner(addr3.address, addr1.address);
    await STT.connect(addr2).replaceOwner(addr3.address, addr1.address);
    const newOwner = await STT.owners(addr3.address);
    expect(newOwner).to.equal(true);
  });

  it("should owner have 10**26 STTS", async () => {
    const totalBalance = (await STTS.balanceOf(owner.address)).toString();
    expect(totalBalance).to.equal("100000000000000000000000000");
  });

  it("should Transfer STTS to another user", async () => {
    await STTS.transfer(addr2.address, "16666666000000000000000000");
    for (let i = 0; i < 5; i++) {
      await STTS.transfer(addrs[i].address, "16666666000000000000000000");
    }
    for (let i = 0; i < 5; i++) {
      expect((await STTS.balanceOf(addrs[i].address)).toString()).to.equal(
        "16666666000000000000000000"
      );
    }
  });

  it("should be only owner allow to recive assets!", async () => {
    expect(STT.withdrawByVote(addrs[8].address, 100)).to.eventually.be.rejectedWith(
      Error,
      "Reciever should be owner"
    );
  });

  it("should vote system reject since address doesn't have stts", async () => {
    expect(STT.connect(addrs[10]).withdrawByVote(addr2.address, 100)).to.eventually.be.rejectedWith(
      Error,
      "Voter doesn't have STTS token!"
    );
  });

  it("should authorized address intract with STT", async () => {
    expect(await STT.elected(addrs[15].address)).to.equal(true);
    const accepted = await addrs[15].sendTransaction({
      value: 1000,
    });
    expect((await STT.assetsBalances(addrs[10].address, addrs[15].address)).toNumber()).to.equal(
      1000
    );
  });

  it("should vote system transfer assets to elected address", async () => {
    expect(await addr3.getBalance()).to.equal("10000000000000000000000");
    expect(await STT.elected(addr3.address)).to.equal(false);
    await STT.connect(addr2).withdrawByVote(addr3.address, 100);
    for (let i = 0; i < 5; i++) {
      await STT.connect(addrs[i]).withdrawByVote(addr3.address, 100);
    }
    expect(await addr3.getBalance()).to.equal("10000000000000000000100");
  });

  // it("should vote system works with stts owners", async () => {
  //   expect(STT.depositAsset(addrs[8].address, 100)).to.eventually.be.rejectedWith(
  //     Error,
  //     "Only from contract"
  //   );
  //   expect(STT.withdrawAsset(addrs[8].address, 100)).to.eventually.be.rejectedWith(
  //     Error,
  //     "Only from contract"
  //   );
  //   expect(
  //     await STT.connect(addrs[4]).withdrawByVote(owner.address, 100)
  //   ).to.eventually.be.rejectedWith(Error, "Only owners can make new nominate!");
  //   await STT.connect(addrs[4]).withdrawByVote(owner.address, 100);
  //   await network.provider.send("evm_increaseTime", [120]);
  //   await network.provider.send("evm_mine");
  // });

  // it("Should recieve TRX", async () => {
  //   await STT.connect(addr3).depositAsset(addrs[4].address, 1000000, {
  //     value: 1000000,
  //   });
  //   const userBalance = await STT.users(addrs[4].address, addr3.address);
  //   expect(userBalance.tronBalance).to.eq(1000000);
  //   expect(userBalance.isActive).to.eq(true);
  // });

  // it("Should Send and recieve TRX from another account", async () => {
  //   await STT.connect(addr3).depositAsset(addrs[8].address, 999999, {
  //     value: 999999,
  //   });
  //   const userBalance1 = await STT.users(addrs[8].address, addr3.address);
  //   expect(userBalance1.tronBalance).to.eq(999999);
  //   expect(userBalance1.isActive).to.eq(true);
  // });

  // it("Should STT price change with number of TRX in bank", async () => {
  //   expect((await STT.sttPrice()).toNumber()).to.eq(1);
  //   await STT.connect(addr3).depositAsset(addrs[9].address, 2, {
  //     value: 2,
  //   });
  //   expect((await STT.sttPrice()).toNumber()).to.eq(2);
  //   await STT.connect(addr3).withdrawAsset(addrs[9].address, 10);
  //   const price = await STT.sttPrice();
  //   console.log("current Price of STT: ", ethers.utils.formatUnits(price, 4));
  //   expect(price.toNumber()).to.eq(1);
  // });

  // it("Shouldn't allow user to mint big amount of STT in small amount of time", async () => {
  //   await expect(
  //     STT.connect(addr3).withdrawAsset(addrs[4].address, 10001)
  //   ).to.eventually.be.rejectedWith(Error, "User try to get STT more than usual!");
  // });

  // it("Should withdraw TRX and get get 10 STT as intrest", async () => {
  //   await STT.connect(addr3).withdrawAsset(addrs[4].address, 10);
  //   const userBalance2 = await STT.users(addrs[4].address, addr3.address);
  //   expect(userBalance2.totalInterest).to.eq(10);
  //   expect(userBalance2.tronBalance).to.eq(0);
  //   expect(userBalance2.isActive).to.eq(false);
  // });
});

// describe("STT trade system", () => {
//   let STTS: STTS;
//   let STT: STT;
//   let addrs: SignerWithAddress[],
//     owner: SignerWithAddress,
//     addr1: SignerWithAddress,
//     addr2: SignerWithAddress,
//     addr3: SignerWithAddress;

//   beforeEach(async function () {
//     [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
//     const STTSFactory = (await ethers.getContractFactory("STTS", owner)) as STTS__factory;
//     const STTFactory = (await ethers.getContractFactory("STT", owner)) as STT__factory;

//     STTS = await STTSFactory.deploy();
//     await STTS.deployed();
//     STT = (await upgrades.deployProxy(
//       STTFactory,
//       [ addr1.address, addr2.address, STTS.address],
//       {initializer: "initialize"}
//     )) as STT;
//     await STT.deployed();
//     const initialSupply = await STT.totalSupply();
//     // 3
//     expect(initialSupply).to.eq(0);
//     expect(STTS.address).to.properAddress;
//     expect(STT.address).to.properAddress;
//     await STT.authorizeContract(addr3.address);
//     await STT.connect(addr1).authorizeContract(addr3.address);
//     await STT.connect(addr2).authorizeContract(addr3.address);
//     const isAuthorized = await STT.elected(addr3.address);
//     expect(isAuthorized).to.eq(true);
//   });

//   it("Should Send and recieve STT", async () => {
//     expect((await STT.balanceOf(addrs[9].address)).toNumber()).to.eq(1000);
//     expect((await STT.balanceOf(STT.address)).toNumber()).to.eq(0);
//     await STT.connect(addrs[9]).approve(STT.address, 10);
//     const result = await STT.allowance(addrs[9].address, STT.address);
//     expect(result.toNumber()).to.eq(10);
//     await STT.connect(addr3).depositStt(addrs[9].address, 10);
//     expect( STT.balanceOf(STT.address)).to.eq(10);
//     const userBalance1 = await STT.users(addrs[9].address, addr3.address);
//     console.log(userBalance1.depositStart.toNumber(), Math.floor(Date.now() / 1000));
//     expect(userBalance1.sttBalance).to.eq(10);
//     expect(userBalance1.isActive).to.eq(true);
//   });

//   it("Should Send and recieve Data", async () => {
//     const text = "hello world";
//     await STT.connect(addr3).saveData(addrs[6].address, ethers.utils.formatBytes32String(text));
//     const userData = await STT.users(addrs[6].address, addr3.address);
//     expect(ethers.utils.parseBytes32String(userData.userData)).to.eq(text);
//   });
// });
