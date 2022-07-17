// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SmartSecure.sol";
import "./SmartMath.sol";
import "./SmartStock.sol";

contract SmartGameStock is SmartSecure {
  using SmartMath for uint256;

  event BuySmartCarStock(address indexed user, uint256 tokenAmount);
  event BuySmartRobotStock(address indexed user, uint256 tokenAmount);

  address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

  uint256 public constant CARS_STOCK_PRICE = 20 * 10**18;
  uint256 public constant ROBOTS_STOCK_PRICE = 10 * 10**18;

  address public SMART_CARS;
  address public SMART_ROBOTS;

  constructor() {
    owner = _msgSender();
    SMART_CARS = address(new SmartStockToken("SmartCarStock", "STC"));
    SMART_ROBOTS = address(new SmartStockToken("SmartRobotStock", "STR"));
  }

  function buySmartRobotStock(uint256 tokenAmount) public {
    uint256 busdAmount = tokenAmount.mul(ROBOTS_STOCK_PRICE);
    require(busdBalanceOf(_msgSender()) > busdAmount, "Error::GameStock, Not enough BUSD!");

    _safeTransferFrom(BUSD, _msgSender(), owner, busdAmount);

    _safeTransfer(SMART_ROBOTS, _msgSender(), tokenAmount);

    emit BuySmartRobotStock(_msgSender(), busdAmount);
  }

  function buySmartCarStock(uint256 tokenAmount) public {
    uint256 busdAmount = tokenAmount.mul(CARS_STOCK_PRICE);
    require(busdBalanceOf(_msgSender()) > busdAmount, "Error::GameStock, Not enough BUSD!");

    _safeTransferFrom(BUSD, _msgSender(), owner, busdAmount);

    _safeTransfer(SMART_CARS, _msgSender(), tokenAmount);

    emit BuySmartCarStock(_msgSender(), busdAmount);
  }

  // User Details
  function busdBalanceOf(address user) public view returns (uint256) {
    return _balanceOf(BUSD, user);
  }

  function stcBalanceOf(address user) public view returns (uint256) {
    return _balanceOf(SMART_CARS, user);
  }

  function strBalanceOf(address user) public view returns (uint256) {
    return _balanceOf(SMART_ROBOTS, user);
  }

  function remainingRobotStock() public view returns (uint256) {
    return _balanceOf(SMART_ROBOTS, address(this));
  }

  function remainingCarStock() public view returns (uint256) {
    return _balanceOf(SMART_CARS, address(this));
  }
}
