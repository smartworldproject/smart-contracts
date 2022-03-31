import {ethers, upgrades} from "hardhat";

async function main() {
  const STTS = await ethers.getContractFactory("STTS");
  const STT = await ethers.getContractFactory("STT");
  const addr1 = "0x167F27341960aC14080F430d60fb6322bAed18Fe",
    addr2 = "0xfDc2e71c6F96F70eB785BB9e18144aadbd2f98b0";

  let STTSContract = await STTS.deploy();
  const withProxy = await upgrades.deployProxy(STT, [addr1, addr2, STTSContract.address], {
    initializer: "initialize",
  });
  console.log("Updradable Contract deployed to:", withProxy.address);
  // If we had constructor arguments, they would be passed into deploy()
  let STTContract = await STT.deploy();

  // The address the Contract WILL have once mined
  console.log(STTSContract.address);
  console.log(STTContract.address);

  // The transaction that was sent to the network to deploy the Contract
  // console.log(STTSContract.deployTransaction.hash);

  // The contract is NOT deployed yet; we must wait until it is mined
  await STTSContract.deployed();
  await STTContract.deployed();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
