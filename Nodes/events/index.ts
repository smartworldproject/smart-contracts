import chalk from "chalk";
import { Contract, EventFilter } from "ethers";
import { ethers } from "hardhat";
import fs from "fs";

const writeToFile = (address: string, events: any) => {
  fs.writeFile(`/referrers/${address}`, JSON.stringify(events), function (err) {
    if (err) console.log(chalk.red(err.message));
  });
};

const getPastEvents = async (
  contract: Contract,
  filter: EventFilter,
  { fromBlock = 16000000, toBlock = "latest", chunkLimit = 5000 }
) => {
  try {
    const fromBlockNumber = +fromBlock;
    const toBlockNumber =
      toBlock === "latest" ? +(await ethers.provider.getBlockNumber()) : +toBlock;
    const totalBlocks = toBlockNumber - fromBlockNumber;
    const chunks = [];

    if (chunkLimit > 0 && totalBlocks > chunkLimit) {
      const count = Math.ceil(totalBlocks / chunkLimit);
      let startingBlock = fromBlockNumber;

      for (let index = 0; index < count; index++) {
        const fromRangeBlock = startingBlock;
        const toRangeBlock = index === count - 1 ? toBlockNumber : startingBlock + chunkLimit;
        startingBlock = toRangeBlock + 1;

        chunks.push({ fromBlock: fromRangeBlock, toBlock: toRangeBlock });
      }
    } else {
      chunks.push({ fromBlock: fromBlockNumber, toBlock: toBlockNumber });
    }

    const events: any[] = [];
    const errors: any[] = [];
    console.log(chunks[0].fromBlock);
    for (const chunk of chunks) {
      chalk.green("Checking BlockNumber " + chunk.fromBlock);
      await contract
        .queryFilter(filter, chunk.fromBlock, chunk.toBlock)
        .then((chunkEvents) => {
          if (chunkEvents?.length > 0) {
            events.push(...chunkEvents);
          }
        })
        .catch((err) => {
          errors.push(err);
        });
    }

    return { events, errors, lastBlock: toBlockNumber };
  } catch (error) {
    return { events: [], errors: [error], lastBlock: null };
  }
};

async function main() {
  const referrer = "0xE75f4aD271C29Bcc1fF51125B0A9CB7636B54b76";
  const contract = await ethers.getContractAt(
    "contracts/Invest4/ISmartInvest04.sol:ISmartInvest04",
    "0xeB2F87B4fF2C35bf1a56B97bAd9bd8Bbf06768bA"
  );
  const filter = contract.filters.RegisterUser(null, referrer, null);

  await getPastEvents(contract, filter, { fromBlock: 16851631 })
    .then((events) => {
      console.log(events);
      writeToFile(referrer, events);
    })
    .catch((err) => console.log(err));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(chalk.red(error));
    process.exit(1);
  });
