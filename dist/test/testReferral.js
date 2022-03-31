"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var hardhat_1 = require("hardhat");
var chai_1 = __importDefault(require("chai"));
var chai_as_promised_1 = __importDefault(require("chai-as-promised"));
var helpers_1 = __importDefault(require("./helpers"));
chai_1.default.use(chai_as_promised_1.default);
var expect = chai_1.default.expect;
describe("Referral", function () {
    var STT;
    var STBank;
    var Ref;
    var addrs, owner, addr1, addr2, addr3;
    before(function () { return __awaiter(void 0, void 0, void 0, function () {
        var STTokenFactory, STBankFactory, RefFactory, _a, _b, initialSupply;
        var _c;
        return __generator(this, function (_d) {
            switch (_d.label) {
                case 0: return [4 /*yield*/, hardhat_1.ethers.getSigners()];
                case 1:
                    // 1
                    _c = _d.sent(), owner = _c[0], addr1 = _c[1], addr2 = _c[2], addr3 = _c[3], addrs = _c.slice(4);
                    return [4 /*yield*/, hardhat_1.ethers.getContractFactory("STT", owner)];
                case 2:
                    STTokenFactory = (_d.sent());
                    return [4 /*yield*/, hardhat_1.ethers.getContractFactory("STBank", owner)];
                case 3:
                    STBankFactory = (_d.sent());
                    return [4 /*yield*/, hardhat_1.ethers.getContractFactory("Referral", owner)];
                case 4:
                    RefFactory = (_d.sent());
                    return [4 /*yield*/, STTokenFactory.deploy()];
                case 5:
                    // 3
                    STT = _d.sent();
                    return [4 /*yield*/, STT.deployed()];
                case 6:
                    _d.sent();
                    return [4 /*yield*/, STBankFactory.deploy([owner.address, addr1.address, addr2.address], STT.address, { value: 1000000 })];
                case 7:
                    // 4
                    STBank = _d.sent();
                    return [4 /*yield*/, STBank.deployed()];
                case 8:
                    _d.sent();
                    return [4 /*yield*/, RefFactory.deploy(STBank.address)];
                case 9:
                    // 5
                    Ref = _d.sent();
                    return [4 /*yield*/, Ref.deployed()];
                case 10:
                    _d.sent();
                    // pass minter role to bank
                    return [4 /*yield*/, STT.passMinterRole(STBank.address)];
                case 11:
                    // pass minter role to bank
                    _d.sent();
                    // authorize contract
                    return [4 /*yield*/, STBank.authorizeContract(Ref.address)];
                case 12:
                    // authorize contract
                    _d.sent();
                    return [4 /*yield*/, STBank.connect(addr1).authorizeContract(Ref.address)];
                case 13:
                    _d.sent();
                    return [4 /*yield*/, STBank.connect(addr2).authorizeContract(Ref.address)];
                case 14:
                    _d.sent();
                    // expect(await Ref.userExpired(owner.address)).to.eq(true);
                    return [4 /*yield*/, Ref.updateFreeze({ value: 700 })];
                case 15:
                    // expect(await Ref.userExpired(owner.address)).to.eq(true);
                    _d.sent();
                    _a = expect;
                    return [4 /*yield*/, Ref.userBalance(owner.address)];
                case 16:
                    _a.apply(void 0, [_d.sent()]).to.eq(700);
                    _b = expect;
                    return [4 /*yield*/, Ref.userExpired(owner.address)];
                case 17:
                    _b.apply(void 0, [_d.sent()]).to.eq(false);
                    return [4 /*yield*/, STT.totalSupply()];
                case 18:
                    initialSupply = _d.sent();
                    expect(initialSupply).to.eq(0);
                    expect(STT.address).to.properAddress;
                    expect(STBank.address).to.properAddress;
                    expect(Ref.address).to.properAddress;
                    return [2 /*return*/];
            }
        });
    }); });
    // 4
    describe("Referral basics", function () {
        it("initial Level price for freeze should be 700 trc", function () { return __awaiter(void 0, void 0, void 0, function () {
            var initialPriceLevel, _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0: return [4 /*yield*/, Ref.freezePrice()];
                    case 1:
                        initialPriceLevel = _b.sent();
                        expect(initialPriceLevel).to.eq(700);
                        _a = expect;
                        return [4 /*yield*/, Ref.totalBalance()];
                    case 2:
                        _a.apply(void 0, [_b.sent()]).to.eq(700);
                        return [2 /*return*/];
                }
            });
        }); });
        it("initial value for some variable", function () { return __awaiter(void 0, void 0, void 0, function () {
            var level;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, Ref.completedLevel(owner.address)];
                    case 1:
                        level = _a.sent();
                        expect(level).to.eq(0);
                        return [2 /*return*/];
                }
            });
        }); });
        it("shouldn't register new user without proper data", function () { return __awaiter(void 0, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, expect(Ref.freeze(owner.address, { value: 700 })).to.eventually.be.rejectedWith(Error, "Error::Refferal, User exist!")];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, expect(Ref.connect(addr1).withdrawIntrest()).to.eventually.be.rejectedWith(Error, "Error::Refferal, User not exist!")];
                    case 2:
                        _a.sent();
                        return [4 /*yield*/, expect(Ref.connect(addr1).freeze(owner.address, { value: 699 })).to.eventually.be.rejectedWith(Error, "Error::Refferal, Incorrect Value!")];
                    case 3:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        }); });
        it("should register new user", function () { return __awaiter(void 0, void 0, void 0, function () {
            var totalBalance, totalBalance2, totalBalance3, i, i, userInfo, user1Info, user1balance, user2Info, u1Levels, u2Levels, currentId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, Ref.connect(addr1).freeze(owner.address, { value: 700 })];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, Ref.totalBalance()];
                    case 2:
                        totalBalance = _a.sent();
                        expect(totalBalance.toNumber()).to.eq(1400);
                        return [4 /*yield*/, Ref.connect(addr2).freeze(addr1.address, { value: 700 })];
                    case 3:
                        _a.sent();
                        return [4 /*yield*/, Ref.totalBalance()];
                    case 4:
                        totalBalance2 = _a.sent();
                        expect(totalBalance2.toNumber()).to.eq(2100);
                        return [4 /*yield*/, Ref.connect(addr3).freeze(addr2.address, { value: 700 })];
                    case 5:
                        _a.sent();
                        return [4 /*yield*/, Ref.totalBalance()];
                    case 6:
                        totalBalance3 = _a.sent();
                        expect(totalBalance3.toNumber()).to.eq(2800);
                        i = 0;
                        _a.label = 7;
                    case 7:
                        if (!(i < 6)) return [3 /*break*/, 10];
                        return [4 /*yield*/, Ref.connect(addrs[i]).freeze(addr3.address, { value: 700 })];
                    case 8:
                        _a.sent();
                        _a.label = 9;
                    case 9:
                        i++;
                        return [3 /*break*/, 7];
                    case 10:
                        i = 6;
                        _a.label = 11;
                    case 11:
                        if (!(i < 12)) return [3 /*break*/, 14];
                        return [4 /*yield*/, Ref.connect(addrs[i]).freeze(addrs[4].address, { value: 700 })];
                    case 12:
                        _a.sent();
                        _a.label = 13;
                    case 13:
                        i++;
                        return [3 /*break*/, 11];
                    case 14: return [4 /*yield*/, Ref.users(owner.address)];
                    case 15:
                        userInfo = _a.sent();
                        expect(userInfo.isExist).to.eq(true);
                        return [4 /*yield*/, Ref.users(addr1.address)];
                    case 16:
                        user1Info = _a.sent();
                        expect(user1Info.isExist).to.eq(true);
                        expect(user1Info.referralID).to.eq(1);
                        return [4 /*yield*/, Ref.userBalance(addr1.address)];
                    case 17:
                        user1balance = _a.sent();
                        expect(user1balance).to.eq(700);
                        return [4 /*yield*/, Ref.users(addr2.address)];
                    case 18:
                        user2Info = _a.sent();
                        expect(user2Info.isExist).to.eq(true);
                        expect(user2Info.referralID).to.eq(2);
                        return [4 /*yield*/, Ref.userReferralList(owner.address)];
                    case 19:
                        u1Levels = _a.sent();
                        expect(u1Levels).ordered.members([1, 1, 1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0]);
                        return [4 /*yield*/, Ref.userReferralList(addr2.address)];
                    case 20:
                        u2Levels = _a.sent();
                        expect(u2Levels).ordered.members([1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                        return [4 /*yield*/, Ref.ID()];
                    case 21:
                        currentId = _a.sent();
                        expect(currentId).to.eq(16);
                        return [2 /*return*/];
                }
            });
        }); });
        it("should withdraw TRON and STT", function () { return __awaiter(void 0, void 0, void 0, function () {
            var _a, _b, _c, _d, uAdLevels, u1AdLevels, u2AdLevels, u3AdLevels, u4AdLevels;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0: return [4 /*yield*/, hardhat_1.network.provider.send("evm_increaseTime", [86400 * 38])];
                    case 1:
                        _e.sent();
                        return [4 /*yield*/, hardhat_1.network.provider.send("evm_mine")];
                    case 2:
                        _e.sent();
                        return [4 /*yield*/, Ref.connect(addr1).withdrawIntrest()];
                    case 3:
                        _e.sent();
                        return [4 /*yield*/, Ref.connect(addrs[10]).unfreeze()];
                    case 4:
                        _e.sent();
                        _a = expect;
                        return [4 /*yield*/, Ref.userBalance(addr1.address)];
                    case 5:
                        _a.apply(void 0, [_e.sent()]).to.eq(700);
                        _b = expect;
                        return [4 /*yield*/, Ref.userBalance(addrs[10].address)];
                    case 6:
                        _b.apply(void 0, [_e.sent()]).to.eq(0);
                        _c = expect;
                        return [4 /*yield*/, STT.balanceOf(addr1.address)];
                    case 7:
                        _c.apply(void 0, [_e.sent()]).to.not.eq(0);
                        _d = expect;
                        return [4 /*yield*/, STT.balanceOf(addrs[10].address)];
                    case 8:
                        _d.apply(void 0, [_e.sent()]).to.not.eq(0);
                        return [4 /*yield*/, Ref.userReferralList(owner.address)];
                    case 9:
                        uAdLevels = _e.sent();
                        expect(uAdLevels).ordered.members([1, 1, 1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0]);
                        return [4 /*yield*/, Ref.userReferralList(addr1.address)];
                    case 10:
                        u1AdLevels = _e.sent();
                        expect(u1AdLevels).ordered.members([1, 1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                        return [4 /*yield*/, Ref.userReferralList(addr2.address)];
                    case 11:
                        u2AdLevels = _e.sent();
                        expect(u2AdLevels).ordered.members([1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                        return [4 /*yield*/, Ref.userReferralList(addr3.address)];
                    case 12:
                        u3AdLevels = _e.sent();
                        expect(u3AdLevels).ordered.members([3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                        return [4 /*yield*/, Ref.userReferralList(addrs[4].address)];
                    case 13:
                        u4AdLevels = _e.sent();
                        expect(u4AdLevels).ordered.members([3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                        return [2 /*return*/];
                }
            });
        }); });
    });
});
describe("Change Values", function () { return __awaiter(void 0, void 0, void 0, function () {
    var STT, STBank, Ref, addrs, owner, addr1, addr2, addr3;
    return __generator(this, function (_a) {
        before(function () { return __awaiter(void 0, void 0, void 0, function () {
            var STTokenFactory, STBankFactory, RefFactory, initialSupply;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0: return [4 /*yield*/, hardhat_1.ethers.getSigners()];
                    case 1:
                        // 1
                        _a = _b.sent(), owner = _a[0], addr1 = _a[1], addr2 = _a[2], addr3 = _a[3], addrs = _a.slice(4);
                        return [4 /*yield*/, hardhat_1.ethers.getContractFactory("STT", owner)];
                    case 2:
                        STTokenFactory = (_b.sent());
                        return [4 /*yield*/, hardhat_1.ethers.getContractFactory("STBank", owner)];
                    case 3:
                        STBankFactory = (_b.sent());
                        return [4 /*yield*/, hardhat_1.ethers.getContractFactory("Referral", owner)];
                    case 4:
                        RefFactory = (_b.sent());
                        return [4 /*yield*/, STTokenFactory.deploy()];
                    case 5:
                        // 3
                        STT = _b.sent();
                        return [4 /*yield*/, STT.deployed()];
                    case 6:
                        _b.sent();
                        return [4 /*yield*/, STBankFactory.deploy([owner.address, addr1.address, addr2.address], STT.address, { value: 1000000 })];
                    case 7:
                        // 4
                        STBank = _b.sent();
                        return [4 /*yield*/, STBank.deployed()];
                    case 8:
                        _b.sent();
                        return [4 /*yield*/, RefFactory.deploy(STBank.address)];
                    case 9:
                        // 5
                        Ref = _b.sent();
                        return [4 /*yield*/, Ref.deployed()];
                    case 10:
                        _b.sent();
                        // pass minter role to bank
                        return [4 /*yield*/, STT.passMinterRole(STBank.address)];
                    case 11:
                        // pass minter role to bank
                        _b.sent();
                        // authorize contract
                        return [4 /*yield*/, STBank.authorizeContract(Ref.address)];
                    case 12:
                        // authorize contract
                        _b.sent();
                        return [4 /*yield*/, STBank.connect(addr1).authorizeContract(Ref.address)];
                    case 13:
                        _b.sent();
                        return [4 /*yield*/, STBank.connect(addr2).authorizeContract(Ref.address)];
                    case 14:
                        _b.sent();
                        return [4 /*yield*/, STT.totalSupply()];
                    case 15:
                        initialSupply = _b.sent();
                        expect(initialSupply).to.eq(0);
                        return [4 /*yield*/, Ref.updateFreeze({ value: 700 })];
                    case 16:
                        _b.sent();
                        expect(STT.address).to.properAddress;
                        expect(STBank.address).to.properAddress;
                        expect(Ref.address).to.properAddress;
                        return [2 /*return*/];
                }
            });
        }); });
        describe("Change value and test again", function () {
            it("should increase Level and price for freeze", function () { return __awaiter(void 0, void 0, void 0, function () {
                var PriceLevel, totalBalance;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            STBank.testMint(1000000, { value: 1000000 });
                            return [4 /*yield*/, Ref.freezePrice()];
                        case 1:
                            PriceLevel = _a.sent();
                            expect(PriceLevel.toNumber()).to.eq(1400);
                            return [4 /*yield*/, Ref.totalBalance()];
                        case 2:
                            totalBalance = _a.sent();
                            expect(totalBalance.toNumber()).to.eq(700);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("shouldn't allow to withdraw for outdated price", function () { return __awaiter(void 0, void 0, void 0, function () {
                var _a, PriceLevel, totalBalance;
                return __generator(this, function (_b) {
                    switch (_b.label) {
                        case 0:
                            _a = expect;
                            return [4 /*yield*/, Ref.updateFreeze({ value: 700 })];
                        case 1: return [4 /*yield*/, _a.apply(void 0, [_b.sent()]).to.eventually.be.rejectedWith(Error, "Error::Refferal, Incorrect Value!")];
                        case 2:
                            _b.sent();
                            return [4 /*yield*/, Ref.freezePrice()];
                        case 3:
                            PriceLevel = _b.sent();
                            expect(PriceLevel.toNumber()).to.eq(1400);
                            return [4 /*yield*/, Ref.totalBalance()];
                        case 4:
                            totalBalance = _b.sent();
                            expect(totalBalance.toNumber()).to.eq(700);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("should register new user again", function () { return __awaiter(void 0, void 0, void 0, function () {
                var PriceLevel, totalBalance, totalBalance2, totalBalance3, i, i, userInfo, user1Info, user1balance, user2Info, u1Levels, u2Levels, currentId;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, Ref.freezePrice()];
                        case 1:
                            PriceLevel = _a.sent();
                            return [4 /*yield*/, Ref.connect(addr1).freeze(owner.address, { value: PriceLevel })];
                        case 2:
                            _a.sent();
                            return [4 /*yield*/, Ref.totalBalance()];
                        case 3:
                            totalBalance = _a.sent();
                            expect(totalBalance.toNumber()).to.eq(2100);
                            return [4 /*yield*/, Ref.connect(addr2).freeze(addr1.address, { value: PriceLevel })];
                        case 4:
                            _a.sent();
                            return [4 /*yield*/, Ref.totalBalance()];
                        case 5:
                            totalBalance2 = _a.sent();
                            expect(totalBalance2.toNumber()).to.eq(3500);
                            return [4 /*yield*/, Ref.connect(addr3).freeze(addr2.address, { value: PriceLevel })];
                        case 6:
                            _a.sent();
                            return [4 /*yield*/, Ref.totalBalance()];
                        case 7:
                            totalBalance3 = _a.sent();
                            expect(totalBalance3.toNumber()).to.eq(4900);
                            i = 0;
                            _a.label = 8;
                        case 8:
                            if (!(i < 6)) return [3 /*break*/, 11];
                            return [4 /*yield*/, Ref.connect(addrs[i]).freeze(addr3.address, { value: 1400 })];
                        case 9:
                            _a.sent();
                            _a.label = 10;
                        case 10:
                            i++;
                            return [3 /*break*/, 8];
                        case 11:
                            i = 6;
                            _a.label = 12;
                        case 12:
                            if (!(i < 12)) return [3 /*break*/, 15];
                            return [4 /*yield*/, Ref.connect(addrs[i]).freeze(addrs[4].address, { value: 1400 })];
                        case 13:
                            _a.sent();
                            _a.label = 14;
                        case 14:
                            i++;
                            return [3 /*break*/, 12];
                        case 15: return [4 /*yield*/, Ref.users(owner.address)];
                        case 16:
                            userInfo = _a.sent();
                            expect(userInfo.isExist).to.eq(true);
                            return [4 /*yield*/, Ref.users(addr1.address)];
                        case 17:
                            user1Info = _a.sent();
                            expect(user1Info.isExist).to.eq(true);
                            expect(user1Info.referralID).to.eq(1);
                            return [4 /*yield*/, Ref.userBalance(addr1.address)];
                        case 18:
                            user1balance = _a.sent();
                            expect(user1balance).to.eq(1400);
                            return [4 /*yield*/, Ref.users(addr3.address)];
                        case 19:
                            user2Info = _a.sent();
                            expect(user2Info.isExist).to.eq(true);
                            expect(user2Info.referralID).to.eq(3);
                            return [4 /*yield*/, Ref.userReferralList(owner.address)];
                        case 20:
                            u1Levels = _a.sent();
                            expect(u1Levels).ordered.members([1, 1, 1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0]);
                            return [4 /*yield*/, Ref.userReferralList(addr2.address)];
                        case 21:
                            u2Levels = _a.sent();
                            expect(u2Levels).ordered.members([1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                            return [4 /*yield*/, Ref.ID()];
                        case 22:
                            currentId = _a.sent();
                            expect(currentId).to.eq(16);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("should withdraw TRON and STT again", function () { return __awaiter(void 0, void 0, void 0, function () {
                var _a, _b, _c, _d, uAdLevels, u1AdLevels, u2AdLevels, u3AdLevels, u4AdLevels;
                return __generator(this, function (_e) {
                    switch (_e.label) {
                        case 0: return [4 /*yield*/, helpers_1.default.wait(1)];
                        case 1:
                            _e.sent();
                            return [4 /*yield*/, Ref.connect(addr1).withdrawIntrest()];
                        case 2:
                            _e.sent();
                            return [4 /*yield*/, Ref.connect(addrs[10]).unfreeze()];
                        case 3:
                            _e.sent();
                            _a = expect;
                            return [4 /*yield*/, Ref.userBalance(addr1.address)];
                        case 4:
                            _a.apply(void 0, [_e.sent()]).to.eq(1400);
                            _b = expect;
                            return [4 /*yield*/, Ref.userBalance(addrs[10].address)];
                        case 5:
                            _b.apply(void 0, [_e.sent()]).to.eq(0);
                            _c = expect;
                            return [4 /*yield*/, STT.balanceOf(addr1.address)];
                        case 6:
                            _c.apply(void 0, [_e.sent()]).to.not.eq(0);
                            _d = expect;
                            return [4 /*yield*/, STT.balanceOf(addrs[10].address)];
                        case 7:
                            _d.apply(void 0, [_e.sent()]).to.not.eq(0);
                            return [4 /*yield*/, Ref.userReferralList(owner.address)];
                        case 8:
                            uAdLevels = _e.sent();
                            expect(uAdLevels).ordered.members([1, 1, 1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0]);
                            return [4 /*yield*/, Ref.userReferralList(addr1.address)];
                        case 9:
                            u1AdLevels = _e.sent();
                            expect(u1AdLevels).ordered.members([1, 1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                            return [4 /*yield*/, Ref.userReferralList(addr2.address)];
                        case 10:
                            u2AdLevels = _e.sent();
                            expect(u2AdLevels).ordered.members([1, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                            return [4 /*yield*/, Ref.userReferralList(addr3.address)];
                        case 11:
                            u3AdLevels = _e.sent();
                            expect(u3AdLevels).ordered.members([3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                            return [4 /*yield*/, Ref.userReferralList(addrs[4].address)];
                        case 12:
                            u4AdLevels = _e.sent();
                            expect(u4AdLevels).ordered.members([3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
                            return [2 /*return*/];
                    }
                });
            }); });
        });
        return [2 /*return*/];
    });
}); });
