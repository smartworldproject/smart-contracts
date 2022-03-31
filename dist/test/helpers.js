"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = {
    RANDOM_ADDRESS: "0x0000000000000000000000000000000000000000",
    EVM_REVERT: "VM Exception while processing transaction: revert",
    DAYS: 86400,
    wait: function (second) {
        var milliseconds = second * 1000;
        return new Promise(function (resolve) { return setTimeout(resolve, milliseconds); });
    },
};
