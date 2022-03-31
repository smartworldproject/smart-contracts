export const RANDOM_ADDRESS = "0x0000000000000000000000000000000000000000";
export const EVM_REVERT = "VM Exception while processing transaction: revert";
export const DAYS = 86400;
export const INITIAL_VALUE = "100000000000000000000000000";
export const wait = (second: number) => {
  const milliseconds = second * 1000;
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
};
