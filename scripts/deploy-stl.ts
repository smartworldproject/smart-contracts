//deploy smartland contract

import { ContractFactory } from "ethers";
import { ethers } from "hardhat";
import { SmartLand } from "../typechain/SmartLand";

async function main() {
  const factory: ContractFactory = await ethers.getContractFactory("SmartLand");
  const contract: SmartLand = (await factory.deploy()) as SmartLand;
  await contract.deployed();

  console.log("SmartLand deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
