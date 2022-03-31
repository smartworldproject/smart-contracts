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
chai_1.default.use(chai_as_promised_1.default);
var expect = chai_1.default.expect;
describe("STT", function () {
    var STT;
    var addrs, owner, addr1, addr2;
    beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
        var STTokenFactory, initialSupply;
        var _a;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0: return [4 /*yield*/, hardhat_1.ethers.getSigners()];
                case 1:
                    // 1
                    _a = _b.sent(), owner = _a[0], addr1 = _a[1], addr2 = _a[2], addrs = _a.slice(3);
                    return [4 /*yield*/, hardhat_1.ethers.getContractFactory("STT", owner)];
                case 2:
                    STTokenFactory = (_b.sent());
                    return [4 /*yield*/, STTokenFactory.deploy()];
                case 3:
                    STT = _b.sent();
                    return [4 /*yield*/, STT.totalSupply()];
                case 4:
                    initialSupply = _b.sent();
                    // 3
                    expect(initialSupply).to.eq(0);
                    expect(STT.address).to.properAddress;
                    return [2 /*return*/];
            }
        });
    }); });
    // 4
    describe("Names and Symbol and Owner", function () { return __awaiter(void 0, void 0, void 0, function () {
        return __generator(this, function (_a) {
            it("should be Smart World Token", function () { return __awaiter(void 0, void 0, void 0, function () {
                var name;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, STT.name()];
                        case 1:
                            name = _a.sent();
                            expect(name).to.eq("Smart Token");
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Should be STT", function () { return __awaiter(void 0, void 0, void 0, function () {
                var symbol;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, STT.symbol()];
                        case 1:
                            symbol = _a.sent();
                            expect(symbol).to.eq("STT");
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Owner Should be equal to first signer", function () { return __awaiter(void 0, void 0, void 0, function () {
                var minter;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, STT.minter()];
                        case 1:
                            minter = _a.sent();
                            expect(minter).to.eq(owner.address);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("Change Minter Role", function () { return __awaiter(void 0, void 0, void 0, function () {
        return __generator(this, function (_a) {
            // 5
            it("should fail due to passMinterRole caller is not the owner", function () {
                return expect(STT.connect(addr1).passMinterRole(addr1.address)).to.eventually.be.rejectedWith(Error, "only owner can change pass minter role");
            });
            it("should pass minter role to another", function () { return __awaiter(void 0, void 0, void 0, function () {
                var minter;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, STT.connect(owner).passMinterRole(addr1.address)];
                        case 1:
                            _a.sent();
                            return [4 /*yield*/, STT.minter()];
                        case 2:
                            minter = _a.sent();
                            expect(minter).to.eq(addr1.address);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("Mint STT", function () { return __awaiter(void 0, void 0, void 0, function () {
        return __generator(this, function (_a) {
            // 5
            it("should fail due to mint caller is not the owner", function () {
                return expect(STT.connect(addr2).mint(addr1.address, 10)).to.eventually.be.rejectedWith(Error, "msg.sender does not have minter role");
            });
            it("should mint 100 STT", function () { return __awaiter(void 0, void 0, void 0, function () {
                var balanceOf;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, STT.mint(addr2.address, 100)];
                        case 1:
                            _a.sent();
                            return [4 /*yield*/, STT.balanceOf(addr2.address)];
                        case 2:
                            balanceOf = _a.sent();
                            expect(balanceOf).to.eq(100);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
});
