"use strict";
var __awaiter =
  (this && this.__awaiter) ||
  function (thisArg, _arguments, P, generator) {
    function adopt(value) {
      return value instanceof P
        ? value
        : new P(function (resolve) {
            resolve(value);
          });
    }
    return new (P || (P = Promise))(function (resolve, reject) {
      function fulfilled(value) {
        try {
          step(generator.next(value));
        } catch (e) {
          reject(e);
        }
      }
      function rejected(value) {
        try {
          step(generator["throw"](value));
        } catch (e) {
          reject(e);
        }
      }
      function step(result) {
        result.done
          ? resolve(result.value)
          : adopt(result.value).then(fulfilled, rejected);
      }
      step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
  };
var __generator =
  (this && this.__generator) ||
  function (thisArg, body) {
    var _ = {
        label: 0,
        sent: function () {
          if (t[0] & 1) throw t[1];
          return t[1];
        },
        trys: [],
        ops: [],
      },
      f,
      y,
      t,
      g;
    return (
      (g = { next: verb(0), throw: verb(1), return: verb(2) }),
      typeof Symbol === "function" &&
        (g[Symbol.iterator] = function () {
          return this;
        }),
      g
    );
    function verb(n) {
      return function (v) {
        return step([n, v]);
      };
    }
    function step(op) {
      if (f) throw new TypeError("Generator is already executing.");
      while (_)
        try {
          if (
            ((f = 1),
            y &&
              (t =
                op[0] & 2
                  ? y["return"]
                  : op[0]
                  ? y["throw"] || ((t = y["return"]) && t.call(y), 0)
                  : y.next) &&
              !(t = t.call(y, op[1])).done)
          )
            return t;
          if (((y = 0), t)) op = [op[0] & 2, t.value];
          switch (op[0]) {
            case 0:
            case 1:
              t = op;
              break;
            case 4:
              _.label++;
              return { value: op[1], done: false };
            case 5:
              _.label++;
              y = op[1];
              op = [0];
              continue;
            case 7:
              op = _.ops.pop();
              _.trys.pop();
              continue;
            default:
              if (
                !((t = _.trys), (t = t.length > 0 && t[t.length - 1])) &&
                (op[0] === 6 || op[0] === 2)
              ) {
                _ = 0;
                continue;
              }
              if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) {
                _.label = op[1];
                break;
              }
              if (op[0] === 6 && _.label < t[1]) {
                _.label = t[1];
                t = op;
                break;
              }
              if (t && _.label < t[2]) {
                _.label = t[2];
                _.ops.push(op);
                break;
              }
              if (t[2]) _.ops.pop();
              _.trys.pop();
              continue;
          }
          op = body.call(thisArg, _);
        } catch (e) {
          op = [6, e];
          y = 0;
        } finally {
          f = t = 0;
        }
      if (op[0] & 5) throw op[1];
      return { value: op[0] ? op[1] : void 0, done: true };
    }
  };
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod };
  };
Object.defineProperty(exports, "__esModule", { value: true });
var hardhat_1 = require("hardhat");
var chai_1 = __importDefault(require("chai"));
var chai_as_promised_1 = __importDefault(require("chai-as-promised"));
var helpers_1 = __importDefault(require("./helpers"));
chai_1.default.use(chai_as_promised_1.default);
var expect = chai_1.default.expect;
describe("STBank", function () {
  var STT;
  var STBank;
  var addrs, owner, addr1, addr2, addr3;
  beforeEach(function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var STTokenFactory, STBankFactory, initialSupply;
      var _a;
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            return [4 /*yield*/, hardhat_1.ethers.getSigners()];
          case 1:
            // 1
            (_a = _b.sent()),
              (owner = _a[0]),
              (addr1 = _a[1]),
              (addr2 = _a[2]),
              (addr3 = _a[3]),
              (addrs = _a.slice(4));
            return [
              4 /*yield*/,
              hardhat_1.ethers.getContractFactory("STT", owner),
            ];
          case 2:
            STTokenFactory = _b.sent();
            return [
              4 /*yield*/,
              hardhat_1.ethers.getContractFactory("STBank", owner),
            ];
          case 3:
            STBankFactory = _b.sent();
            return [4 /*yield*/, STTokenFactory.deploy()];
          case 4:
            STT = _b.sent();
            return [4 /*yield*/, STT.deployed()];
          case 5:
            _b.sent();
            return [
              4 /*yield*/,
              STBankFactory.deploy(
                [owner.address, addr1.address, addr2.address],
                STT.address
              ),
            ];
          case 6:
            STBank = _b.sent();
            return [4 /*yield*/, STBank.deployed()];
          case 7:
            _b.sent();
            return [4 /*yield*/, STT.totalSupply()];
          case 8:
            initialSupply = _b.sent();
            return [4 /*yield*/, STT.passMinterRole(STBank.address)];
          case 9:
            _b.sent();
            // 3
            expect(initialSupply).to.eq(0);
            expect(STT.address).to.properAddress;
            expect(STBank.address).to.properAddress;
            return [2 /*return*/];
        }
      });
    });
  });
  // 4
  describe("STbank Owners", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        it("wrong address Shouldn't be equal to Owner", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            var newOwner;
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  return [4 /*yield*/, STBank.owners(addr3.address)];
                case 1:
                  newOwner = _a.sent();
                  expect(newOwner).to.eq(false);
                  return [2 /*return*/];
              }
            });
          });
        });
        it("Owner Should be equal to first signer", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            var newOwner;
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  return [4 /*yield*/, STBank.owners(owner.address)];
                case 1:
                  newOwner = _a.sent();
                  expect(newOwner).to.eq(true);
                  return [2 /*return*/];
              }
            });
          });
        });
        it("Second Owner Should be equal to second signer", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            var newOwner;
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  return [4 /*yield*/, STBank.owners(addr1.address)];
                case 1:
                  newOwner = _a.sent();
                  expect(newOwner).to.eq(true);
                  return [2 /*return*/];
              }
            });
          });
        });
        it("Third Owner Should be equal to third signer", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            var newOwner;
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  return [4 /*yield*/, STBank.owners(addr2.address)];
                case 1:
                  newOwner = _a.sent();
                  expect(newOwner).to.eq(true);
                  return [2 /*return*/];
              }
            });
          });
        });
        return [2 /*return*/];
      });
    });
  });
  describe("Change Owner", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        // 5
        it("Should fail due to caller is not the owner", function () {
          return expect(
            STBank.connect(addr3).replaceOwnership(addr3.address, addr1.address)
          ).to.eventually.be.rejectedWith(Error, "Only from owners!");
        });
        it("Should Replace Owner role to another", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            var newOwner;
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  return [
                    4 /*yield*/,
                    STBank.connect(owner).replaceOwnership(
                      addr3.address,
                      addr1.address
                    ),
                  ];
                case 1:
                  _a.sent();
                  return [
                    4 /*yield*/,
                    STBank.connect(addr1).replaceOwnership(
                      addr3.address,
                      addr1.address
                    ),
                  ];
                case 2:
                  _a.sent();
                  return [
                    4 /*yield*/,
                    STBank.connect(addr2).replaceOwnership(
                      addr3.address,
                      addr1.address
                    ),
                  ];
                case 3:
                  _a.sent();
                  return [4 /*yield*/, STBank.owners(addr3.address)];
                case 4:
                  newOwner = _a.sent();
                  expect(newOwner).to.eq(true);
                  return [2 /*return*/];
              }
            });
          });
        });
        return [2 /*return*/];
      });
    });
  });
  describe("Authorize Contract", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        // 5
        it("Should fail due to caller is not the owner", function () {
          return expect(
            STBank.connect(addr3).authorizeContract(
              helpers_1.default.RANDOM_ADDRESS
            )
          ).to.eventually.be.rejectedWith(Error, "Only from owners!");
        });
        it("Should fail due to caller is already voted", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  return [
                    4 /*yield*/,
                    STBank.authorizeContract(helpers_1.default.RANDOM_ADDRESS),
                  ];
                case 1:
                  _a.sent();
                  expect(
                    STBank.authorizeContract(helpers_1.default.RANDOM_ADDRESS)
                  ).to.eventually.be.rejectedWith(
                    Error,
                    "You already voted for this address!"
                  );
                  return [2 /*return*/];
              }
            });
          });
        });
        it("Shouldn't Authorize contract after 2 seconds", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            var onVote, isAuthorized;
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  return [
                    4 /*yield*/,
                    STBank.authorizeContract(helpers_1.default.RANDOM_ADDRESS),
                  ];
                case 1:
                  _a.sent();
                  return [
                    4 /*yield*/,
                    STBank.connect(addr1).authorizeContract(
                      helpers_1.default.RANDOM_ADDRESS
                    ),
                  ];
                case 2:
                  _a.sent();
                  return [
                    4 /*yield*/,
                    STBank.onVote(helpers_1.default.RANDOM_ADDRESS),
                  ];
                case 3:
                  onVote = _a.sent();
                  expect(onVote.voted).to.eq(2);
                  return [4 /*yield*/, helpers_1.default.wait(2)];
                case 4:
                  _a.sent();
                  return [
                    4 /*yield*/,
                    STBank.connect(addr2).authorizeContract(
                      helpers_1.default.RANDOM_ADDRESS
                    ),
                  ];
                case 5:
                  _a.sent();
                  return [
                    4 /*yield*/,
                    STBank.smartContracts(helpers_1.default.RANDOM_ADDRESS),
                  ];
                case 6:
                  isAuthorized = _a.sent();
                  expect(isAuthorized).to.eq(false);
                  return [2 /*return*/];
              }
            });
          });
        });
        it("Should Authorize contract", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            var onVote, isAuthorized;
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  return [4 /*yield*/, STBank.authorizeContract(addr3.address)];
                case 1:
                  _a.sent();
                  return [
                    4 /*yield*/,
                    STBank.connect(addr1).authorizeContract(addr3.address),
                  ];
                case 2:
                  _a.sent();
                  return [4 /*yield*/, STBank.onVote(addr3.address)];
                case 3:
                  onVote = _a.sent();
                  expect(onVote.voted).to.eq(2);
                  return [
                    4 /*yield*/,
                    STBank.connect(addr2).authorizeContract(addr3.address),
                  ];
                case 4:
                  _a.sent();
                  return [4 /*yield*/, STBank.smartContracts(addr3.address)];
                case 5:
                  isAuthorized = _a.sent();
                  expect(isAuthorized).to.eq(true);
                  return [2 /*return*/];
              }
            });
          });
        });
        it("Shouldn't accept Deposit and Withdraw from unauthorized address", function () {
          return __awaiter(void 0, void 0, void 0, function () {
            return __generator(this, function (_a) {
              expect(
                STBank.depositAsset(helpers_1.default.RANDOM_ADDRESS, 100)
              ).to.eventually.be.rejectedWith(Error, "Only from contract");
              expect(
                STBank.withdrawAsset(helpers_1.default.RANDOM_ADDRESS, 100)
              ).to.eventually.be.rejectedWith(Error, "Only from contract");
              return [2 /*return*/];
            });
          });
        });
        return [2 /*return*/];
      });
    });
  });
});
describe("STBank Trx trade system", function () {
  var STT;
  var STBank;
  var addrs, owner, addr1, addr2, addr3;
  before(function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var STTokenFactory, STBankFactory, initialSupply, isAuthorized;
      var _a;
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            return [4 /*yield*/, hardhat_1.ethers.getSigners()];
          case 1:
            // 1
            (_a = _b.sent()),
              (owner = _a[0]),
              (addr1 = _a[1]),
              (addr2 = _a[2]),
              (addr3 = _a[3]),
              (addrs = _a.slice(4));
            return [
              4 /*yield*/,
              hardhat_1.ethers.getContractFactory("STT", owner),
            ];
          case 2:
            STTokenFactory = _b.sent();
            return [
              4 /*yield*/,
              hardhat_1.ethers.getContractFactory("STBank", owner),
            ];
          case 3:
            STBankFactory = _b.sent();
            return [4 /*yield*/, STTokenFactory.deploy()];
          case 4:
            STT = _b.sent();
            return [4 /*yield*/, STT.deployed()];
          case 5:
            _b.sent();
            return [
              4 /*yield*/,
              STBankFactory.deploy(
                [owner.address, addr1.address, addr2.address],
                STT.address
              ),
            ];
          case 6:
            STBank = _b.sent();
            return [4 /*yield*/, STBank.deployed()];
          case 7:
            _b.sent();
            return [4 /*yield*/, STT.totalSupply()];
          case 8:
            initialSupply = _b.sent();
            return [4 /*yield*/, STT.passMinterRole(STBank.address)];
          case 9:
            _b.sent();
            // 3
            expect(initialSupply).to.eq(0);
            expect(STT.address).to.properAddress;
            expect(STBank.address).to.properAddress;
            return [4 /*yield*/, STBank.authorizeContract(addr3.address)];
          case 10:
            _b.sent();
            return [
              4 /*yield*/,
              STBank.connect(addr1).authorizeContract(addr3.address),
            ];
          case 11:
            _b.sent();
            return [
              4 /*yield*/,
              STBank.connect(addr2).authorizeContract(addr3.address),
            ];
          case 12:
            _b.sent();
            return [4 /*yield*/, STBank.smartContracts(addr3.address)];
          case 13:
            isAuthorized = _b.sent();
            expect(isAuthorized).to.eq(true);
            return [2 /*return*/];
        }
      });
    });
  });
  it("Should recieve TRX", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var userBalance;
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            return [
              4 /*yield*/,
              STBank.connect(addr3).depositAsset(addrs[4].address, 1000000, {
                value: 1000000,
              }),
            ];
          case 1:
            _a.sent();
            return [4 /*yield*/, STBank.users(addrs[4].address, addr3.address)];
          case 2:
            userBalance = _a.sent();
            expect(userBalance.tronBalance).to.eq(1000000);
            expect(userBalance.isActive).to.eq(true);
            return [2 /*return*/];
        }
      });
    });
  });
  it("Should Send and recieve TRX from another account", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var userBalance1;
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            return [
              4 /*yield*/,
              STBank.connect(addr3).depositAsset(addrs[8].address, 999999, {
                value: 999999,
              }),
            ];
          case 1:
            _a.sent();
            return [4 /*yield*/, STBank.users(addrs[8].address, addr3.address)];
          case 2:
            userBalance1 = _a.sent();
            expect(userBalance1.tronBalance).to.eq(999999);
            expect(userBalance1.isActive).to.eq(true);
            return [2 /*return*/];
        }
      });
    });
  });
  it("Should STT price change with number of TRX in bank", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var _a, _b, price;
      return __generator(this, function (_c) {
        switch (_c.label) {
          case 0:
            _a = expect;
            return [4 /*yield*/, STBank.sttPrice()];
          case 1:
            _a.apply(void 0, [_c.sent().toNumber()]).to.eq(1);
            return [
              4 /*yield*/,
              STBank.connect(addr3).depositAsset(addrs[9].address, 2, {
                value: 2,
              }),
            ];
          case 2:
            _c.sent();
            _b = expect;
            return [4 /*yield*/, STBank.sttPrice()];
          case 3:
            _b.apply(void 0, [_c.sent().toNumber()]).to.eq(2);
            return [
              4 /*yield*/,
              STBank.connect(addr3).withdrawAsset(addrs[9].address, 10),
            ];
          case 4:
            _c.sent();
            return [4 /*yield*/, STBank.sttPrice()];
          case 5:
            price = _c.sent();
            console.log(
              "current Price of STT: ",
              hardhat_1.ethers.utils.formatUnits(price, 4)
            );
            expect(price.toNumber()).to.eq(1);
            return [2 /*return*/];
        }
      });
    });
  });
  it("Shouldn't allow user to mint big amount of STT in small amount of time", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            return [
              4 /*yield*/,
              expect(
                STBank.connect(addr3).withdrawAsset(addrs[4].address, 10001)
              ).to.eventually.be.rejectedWith(
                Error,
                "User try to get STT more than usual!"
              ),
            ];
          case 1:
            _a.sent();
            return [2 /*return*/];
        }
      });
    });
  });
  it("Should withdraw TRX and get get 10 STT as intrest", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var userBalance2;
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            return [
              4 /*yield*/,
              STBank.connect(addr3).withdrawAsset(addrs[4].address, 10),
            ];
          case 1:
            _a.sent();
            return [4 /*yield*/, STBank.users(addrs[4].address, addr3.address)];
          case 2:
            userBalance2 = _a.sent();
            expect(userBalance2.totalInterest).to.eq(10);
            expect(userBalance2.tronBalance).to.eq(0);
            expect(userBalance2.isActive).to.eq(false);
            return [2 /*return*/];
        }
      });
    });
  });
});
describe("STBank STT trade system", function () {
  var STT;
  var STBank;
  var addrs, owner, addr1, addr2, addr3;
  before(function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var STTokenFactory, STBankFactory, _a, _b, isAuthorized;
      var _c;
      return __generator(this, function (_d) {
        switch (_d.label) {
          case 0:
            return [4 /*yield*/, hardhat_1.ethers.getSigners()];
          case 1:
            // 1
            (_c = _d.sent()),
              (owner = _c[0]),
              (addr1 = _c[1]),
              (addr2 = _c[2]),
              (addr3 = _c[3]),
              (addrs = _c.slice(4));
            return [
              4 /*yield*/,
              hardhat_1.ethers.getContractFactory("STT", owner),
            ];
          case 2:
            STTokenFactory = _d.sent();
            return [
              4 /*yield*/,
              hardhat_1.ethers.getContractFactory("STBank", owner),
            ];
          case 3:
            STBankFactory = _d.sent();
            return [4 /*yield*/, STTokenFactory.deploy()];
          case 4:
            STT = _d.sent();
            return [4 /*yield*/, STT.deployed()];
          case 5:
            _d.sent();
            return [
              4 /*yield*/,
              STBankFactory.deploy(
                [owner.address, addr1.address, addr2.address],
                STT.address
              ),
            ];
          case 6:
            STBank = _d.sent();
            return [4 /*yield*/, STBank.deployed()];
          case 7:
            _d.sent();
            _a = expect;
            return [4 /*yield*/, STT.totalSupply()];
          case 8:
            _a.apply(void 0, [_d.sent()]).to.eq(0);
            addrs.forEach(function (add) {
              return __awaiter(void 0, void 0, void 0, function () {
                var _a;
                return __generator(this, function (_b) {
                  switch (_b.label) {
                    case 0:
                      return [4 /*yield*/, STT.mint(add.address, 1000)];
                    case 1:
                      _b.sent();
                      _a = expect;
                      return [4 /*yield*/, STT.balanceOf(add.address)];
                    case 2:
                      _a.apply(void 0, [_b.sent().toNumber()]).to.eq(1000);
                      return [2 /*return*/];
                  }
                });
              });
            });
            return [4 /*yield*/, STT.passMinterRole(STBank.address)];
          case 9:
            _d.sent();
            // 3
            _b = expect;
            return [4 /*yield*/, STT.totalSupply()];
          case 10:
            // 3
            _b.apply(void 0, [_d.sent()]).to.eq(16000);
            expect(STT.address).to.properAddress;
            expect(STBank.address).to.properAddress;
            return [4 /*yield*/, STBank.authorizeContract(addr3.address)];
          case 11:
            _d.sent();
            return [
              4 /*yield*/,
              STBank.connect(addr1).authorizeContract(addr3.address),
            ];
          case 12:
            _d.sent();
            return [
              4 /*yield*/,
              STBank.connect(addr2).authorizeContract(addr3.address),
            ];
          case 13:
            _d.sent();
            return [4 /*yield*/, STBank.smartContracts(addr3.address)];
          case 14:
            isAuthorized = _d.sent();
            expect(isAuthorized).to.eq(true);
            return [2 /*return*/];
        }
      });
    });
  });
  it("Should Send and recieve STT", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var _a, _b, result, _c, userBalance1;
      return __generator(this, function (_d) {
        switch (_d.label) {
          case 0:
            _a = expect;
            return [4 /*yield*/, STT.balanceOf(addrs[9].address)];
          case 1:
            _a.apply(void 0, [_d.sent().toNumber()]).to.eq(1000);
            _b = expect;
            return [4 /*yield*/, STT.balanceOf(STBank.address)];
          case 2:
            _b.apply(void 0, [_d.sent().toNumber()]).to.eq(0);
            return [
              4 /*yield*/,
              STT.connect(addrs[9]).approve(STBank.address, 10),
            ];
          case 3:
            _d.sent();
            return [
              4 /*yield*/,
              STT.allowance(addrs[9].address, STBank.address),
            ];
          case 4:
            result = _d.sent();
            expect(result.toNumber()).to.eq(10);
            return [
              4 /*yield*/,
              STBank.connect(addr3).depositStt(addrs[9].address, 10),
            ];
          case 5:
            _d.sent();
            _c = expect;
            return [4 /*yield*/, STT.balanceOf(STBank.address)];
          case 6:
            _c.apply(void 0, [_d.sent()]).to.eq(10);
            return [4 /*yield*/, STBank.users(addrs[9].address, addr3.address)];
          case 7:
            userBalance1 = _d.sent();
            console.log(
              userBalance1.depositStart.toNumber(),
              Math.floor(Date.now() / 1000)
            );
            expect(userBalance1.sttBalance).to.eq(10);
            expect(userBalance1.isActive).to.eq(true);
            return [2 /*return*/];
        }
      });
    });
  });
  it("Should Send and recieve Data", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var text, userData;
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            text = "hello world";
            return [
              4 /*yield*/,
              STBank.connect(addr3).saveData(
                addrs[6].address,
                hardhat_1.ethers.utils.formatBytes32String(text)
              ),
            ];
          case 1:
            _a.sent();
            return [4 /*yield*/, STBank.users(addrs[6].address, addr3.address)];
          case 2:
            userData = _a.sent();
            expect(
              hardhat_1.ethers.utils.parseBytes32String(userData.userData)
            ).to.eq(text);
            return [2 /*return*/];
        }
      });
    });
  });
});
