import chalk from "chalk";
import { ethers } from "hardhat";
import { ISmartInvest03, ISmartInvest04 } from "../../typechain";
// import tokenHolders from "./tokenholders.json";
import fs from "fs";

var needMigrate = require("./needMigrate.json");
var succeedMigrate = require("./succeed.json");
var failedMigrate = require("./failed.json");
const needMigrateFileName = "./migrate/needMigrate.json";
const succeedFileName = "./migrate/succeed.json";
const failedFileName = "./migrate/failed.json";

const writeToSucceed = (address: string) => {
  succeedMigrate[address] = true;
  fs.writeFile(succeedFileName, JSON.stringify(succeedMigrate), function (err) {
    if (err) console.log(chalk.red(err.message));
  });
};

const writeToNeedMigrate = (address: string) => {
  needMigrate[address] = true;
  fs.writeFile(needMigrateFileName, JSON.stringify(needMigrate), function (err) {
    if (err) console.log(chalk.red(err.message));
  });
};

const writeToFailed = (address: string, error: string) => {
  failedMigrate[address] = error;
  fs.writeFile(failedFileName, JSON.stringify(failedMigrate), function (err) {
    if (err) console.log(chalk.red(err.message));
  });
};

const wait = (second: number) => {
  const milliseconds = second * 1000;
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
};

const tokenHolders = ["0x084FE9f56f609a237891C96bE4D69f1B7052c9Ed"];

async function main() {
  const firstAddress = "0xbBe476b50D857BF41bBd1EB02F777cb9084C1564";

  const Invest03 = (await ethers.getContractAt(
    "contracts/Invest4/ISmartInvest03.sol:ISmartInvest03",
    "0x59FD37b88780a7F5be75f0A5B9afeA7cf94eF0ff"
  )) as ISmartInvest03;

  const Invest04 = (await ethers.getContractAt(
    "contracts/Invest4/ISmartInvest04.sol:ISmartInvest04",
    "0xeB2F87B4fF2C35bf1a56B97bAd9bd8Bbf06768bA"
  )) as ISmartInvest04;

  let parents = 0;

  const checkLine = async (address: string): Promise<string> => {
    if (address === firstAddress) return firstAddress;
    const { referrer } = await Invest04.users(address);
    parents++;
    console.log(referrer, parents);
    if (referrer === "0x0000000000000000000000000000000000000000") {
      const { referrer } = await Invest03.users(address);
      if (referrer !== "0x0000000000000000000000000000000000000000") return address;
      else {
        console.log(chalk.magentaBright(address + " is not exist on Invest03!"));
        return firstAddress;
      }
    } else {
      return checkLine(referrer);
    }
  };

  const numberOfAdress = tokenHolders.length;
  for (let i = 0; i < numberOfAdress; i++) {
    const address = tokenHolders[i];

    console.log(chalk.cyan(i + 1 + "-checking: ") + chalk.blue(address));

    let migrateAddress = firstAddress;

    if (!succeedMigrate[address]) migrateAddress = await checkLine(address);

    if (succeedMigrate[migrateAddress]) {
      console.log(chalk.green("Not Need Migrate: ") + address);
      writeToSucceed(address);
    }
    if (!succeedMigrate[migrateAddress]) {
      console.log(chalk.yellow("Need Migrate: ") + migrateAddress);
      writeToNeedMigrate(migrateAddress);
      Invest04.migrateByAdmin(migrateAddress)
        .then(({ hash }: { hash: string }) => {
          console.log(chalk.magenta("tx: ") + hash);
          writeToSucceed(migrateAddress);
        })
        .catch((err: any) => {
          writeToFailed(migrateAddress, err.reason);
        });
    }
    const percent = (i / numberOfAdress) * 100;
    console.log(
      chalk.greenBright(`---------------------${percent.toFixed(2)}%----------------------`)
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(chalk.red(error));
    process.exit(1);
  });
