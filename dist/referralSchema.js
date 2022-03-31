"use strict";
var currentLevel = 1;
var refCompleteDepth = 1;
var REFERRER_1_LEVEL_LIMIT = 3;
var Users = {};
var userList = {};
var userRefComplete = {};
var profitStat = {};
var levelStat = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
var currUserID = 0;
Users["0x0"] = {
    id: 0,
    referral: [],
    isActive: true,
    time: Date.now(),
    levelStat: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
};
userList[currUserID] = "0x0";
function registerUser(_referrerID, _sender, _value) {
    currUserID++;
    Users[_sender] = {
        id: currUserID,
        referral: [],
        isActive: true,
        time: Date.now() + 3600,
        levelStat: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    };
    userList[currUserID] = _sender;
    Users[userList[_referrerID]].referral.push(_sender);
}
function currentLevelPrice() {
    return currentLevel * 700;
}
function regUser(_referrer, _sender, _value) {
    var _a, _b;
    if ((_a = Users[_sender]) === null || _a === void 0 ? void 0 : _a.isActive) {
        console.log("Error::Refferal, User exist");
        return;
    }
    var _referrerID = 0;
    if ((_b = Users[_referrer]) === null || _b === void 0 ? void 0 : _b.isActive) {
        _referrerID = Users[_referrer].id;
        Users[_referrer].levelStat;
    }
    else if (_referrer == "") {
        _referrerID = findFirstFreeReferrer();
        refCompleteDepth = _referrerID;
    }
    else {
        console.log("Error::Refferal, Incorrect referrer");
        return;
    }
    if (_referrerID < 0 && _referrerID >= currUserID) {
        console.log("Error::Refferal, Incorrect referrer Id");
        return;
    }
    if (_value != currentLevelPrice()) {
        console.log("Error::Refferal, Incorrect Value");
        return;
    }
    if (Users[userList[_referrerID]].referral.length >= REFERRER_1_LEVEL_LIMIT) {
        _referrerID = Users[findFreeReferrer(userList[_referrerID])].id;
    }
    registerUser(_referrerID, _sender, _value);
    if (Users[userList[_referrerID]].referral.length == 3) {
        userRefComplete[_referrerID] = true;
    }
    payForLevel(currentLevel, _sender, _referrer, _value);
}
function findFreeReferrer(_user) {
    if (Users[_user].referral.length < REFERRER_1_LEVEL_LIMIT) {
        return _user;
    }
    var referrals = new Array(363);
    referrals[0] = Users[_user].referral[0];
    referrals[1] = Users[_user].referral[1];
    referrals[2] = Users[_user].referral[2];
    var freeReferrer = "0x0";
    var noFreeReferrer = true;
    for (var i = 0; i < 363; i++) {
        if (Users[referrals[i]].referral.length == REFERRER_1_LEVEL_LIMIT) {
            if (i < 120) {
                referrals[(i + 1) * 3] = Users[referrals[i]].referral[0];
                referrals[(i + 1) * 3 + 1] = Users[referrals[i]].referral[1];
                referrals[(i + 1) * 3 + 2] = Users[referrals[i]].referral[2];
            }
        }
        else {
            noFreeReferrer = false;
            freeReferrer = referrals[i];
            break;
        }
    }
    if (noFreeReferrer) {
        freeReferrer = userList[findFirstFreeReferrer()];
    }
    return freeReferrer;
}
function findFirstFreeReferrer() {
    var free = 0;
    for (var i = refCompleteDepth; i < 500 + refCompleteDepth; i++) {
        if (!userRefComplete[i]) {
            free = i;
        }
    }
    return free;
}
function payForLevel(_level, _user, referer, _value) {
    var _a;
    if (!((_a = Users[referer]) === null || _a === void 0 ? void 0 : _a.isActive)) {
        referer = userList[1];
    }
    if (referer == userList[1]) {
    }
    else if (!profitStat[referer]) {
        profitStat[referer] = _value;
    }
    else {
        profitStat[referer] += _value;
    }
    levelStat[_level - 1]++;
}
for (var i = 1; i < 60; i++) {
    if (i > 30) {
        currentLevel = 2;
        if (i > 45)
            currentLevel = 4;
        regUser("0x" + Math.floor(Math.random() * 50), "0x" + i, currentLevelPrice());
    }
    else
        regUser("0x0", "0x" + i, 700);
}
// console.log(Users);
// console.log("LevelState", levelStat);
// console.log("List", userList);
// console.log("UserComplete", userRefComplete);
// console.log(profitStat);
