// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./SmartSecure.sol";
import "./SmartUint.sol";

contract SmartLand is ERC721Enumerable, SmartSecure {
  using SmartUint for uint256;

  event ReferralReceived(address indexed user, address from, uint256 value);

  struct UserStruct {
    address referrer;
    uint256 refAmounts;
  }

  mapping(address => UserStruct) public users;

  uint256 maxSupply = 10_000;

  constructor() ERC721("SmartLand", "STL") {
    owner = msg.sender;
    gameMaster = msg.sender;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return string(abi.encodePacked(BASE_URL, tokenId.toString(), BASE_EXT));
  }

  function mint(
    address referrer,
    uint256 tokenId,
    bytes memory data
  ) public payable {
    require(tokenId < maxSupply && !_exists(tokenId), "Error::SmartLand, NFT does not exist!");
    require(msg.value >= LAND_PRICE, "Error::SmartLand, Incorrect Value!");
    require(data.length == 16, "Error::SmartLand, Incorrect Data!");

    transferToOwner();

    landData[tokenId] = data;

    if (notExist(_msgSender())) {
      if (referrer == address(0)) {
        users[_msgSender()].referrer = address(1);
      } else if (exist(referrer)) {
        users[_msgSender()].referrer = referrer;

        payReferrer(referrer);
      } else {
        revert("Error::SmartLand, Referrer does not exist!");
      }
    }

    _safeMint(msg.sender, tokenId);
  }

  function payReferrer(address referrer) private {
    uint256 refAmount = LAND_PRICE.percent(REFERRAL_PERCENT);
    users[referrer].refAmounts = users[referrer].refAmounts.add(refAmount);

    emit ReferralReceived(referrer, _msgSender(), refAmount);
  }

  function withdrawInterest() public nonReentrant {
    uint256 amount = users[_msgSender()].refAmounts;
    require(amount > 0, "Error::SmartLand, Zero Interest!");

    users[_msgSender()].refAmounts = 0;
    _safeTransferETH(_msgSender(), amount);
  }

  function exist(address account) public view returns (bool) {
    return users[account].referrer != address(0);
  }

  function notExist(address account) public view returns (bool) {
    return users[account].referrer == address(0);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override {
    if (from == address(0)) {
      require(totalSupply() < maxSupply, "Error::SmartLand, Max Supply!");
    } else {
      require(!PAUSED, "Error::SmartLand, Transfer Paused!");
    }

    super._beforeTokenTransfer(from, to, tokenId);
  }

  receive() external payable {}
}
