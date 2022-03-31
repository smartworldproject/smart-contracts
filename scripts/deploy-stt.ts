import {ethers} from "hardhat";

async function main() {
  const addr1 = "0x167F27341960aC14080F430d60fb6322bAed18Fe",
    addr2 = "0xfDc2e71c6F96F70eB785BB9e18144aadbd2f98b0",
    STTSContractAddress = "0xdcAB244d44CfCd91d7d70708F16A77c38653C8d8";

  const STTFactory = await ethers.getContractFactory("STT");

  const STT = await STTFactory.deploy(addr1, addr2, STTSContractAddress);
  await STT.deployed();
  console.log("STT Contract deployed to: ", STT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
