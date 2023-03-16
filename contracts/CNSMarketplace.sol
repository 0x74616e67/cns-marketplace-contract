// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IStore.sol";

// error NotListed(address nftAddress, uint256 tokenId);
// error AlreadyListed(address nftAddress, uint256 tokenId);
// error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
// error NotOwner();
// error PriceMustBeAboveZero(uint256);
// error NotApprovedForMarketplace();
// error NotInWhitelist(address nftAddress);
// error FeeMustBeGreZeroAndLreOneHundred(uint256);

/**
Error Code:

1. 1001, Not listed
2. 1002, Already listed
3. 1003, Price not met
4. 1004, Not owner
5. 1005, Price must be above zero
6. 1006, Not approved for marketplace
8. 1008, Not in whitelist
9. 1009, Fee must be greater or equal to 0, and less or equal to 100
*/

contract CNSMarketplace is ReentrancyGuard, Ownable {

  address public store;

  address public vault;

  // 25 / 1000
  uint8 public fee = 25;

  struct Listing {
    uint256 price;
    address seller;
  }

  event ItemListed(
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price
  );

  event ItemCanceled(
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed tokenId
  );

  event ItemBought(
    address indexed buyer,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price
  );

  event UpdateStore(
    address indexed prev,
    address indexed next
  );

  event UpdateVault(
    address indexed prev,
    address indexed next
  );

  event UpdateWhitelist(
    address indexed nftAddress,
    bool indexed flag
  );

  event UpdateFee(
    uint8 prev,
    uint8 curr
  );

  mapping(address => mapping(uint256 => Listing)) private listings;
  mapping(address => bool) public whitelist;

  modifier isListed(
    address nftAddress,
    uint256 tokenId
  ) {
    Listing memory listing = listings[nftAddress][tokenId];

    require(listing.price > 0, "1001, Not listed");

    _;
  }

  modifier isNotListed(
    address nftAddress,
    uint256 tokenId
  ) {
    Listing memory listing = listings[nftAddress][tokenId];

    require(listing.price <= 0, "1002, Already listed");

    _;
  }

  modifier isApproved(address nftAddress, uint256 tokenId) {
    IERC1155 nft = IERC1155(nftAddress);
    
    require(nft.isApprovedForAll(listings[nftAddress][tokenId].seller, address(this)), "1006, Not approved for marketplace");

    _;
  }

  modifier isOwner(
    address nftAddress,
    uint256 tokenId,
    address spender
  ) {
    IERC1155 nft = IERC1155(nftAddress);
    uint256 balance = nft.balanceOf(spender, tokenId);
    
    require(balance > 0, "1004, Not owner");
    
    _;
  }

  function updateWhitelist(address nftAddress, bool flag) public onlyOwner {
    whitelist[nftAddress] = flag;

    emit UpdateWhitelist(nftAddress, flag);
  }

  function updateStore(address _store) public onlyOwner {
    address prev = store;
    store = _store;

    emit UpdateStore(prev, _store);
  }

  function updateVault(address _vault) public onlyOwner {
    address prev = vault;
    vault = _vault;

    emit UpdateVault(prev, _vault);
  }

  function updateFee(uint8 _fee) public onlyOwner {
    require(fee >= 0 && fee <= 1000, "1009, Fee must be greater or equal to 0, and less or equal to 1000");
    
    uint8 prev = fee;
    fee = _fee;

    emit UpdateFee(prev, fee);
  }

  function listItem(
    address nftAddress,
    uint256 tokenId,
    uint256 price
  ) external isNotListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) {
    require(whitelist[nftAddress], "1008, Not in whitelist");

    require(price > 0, "1005, Price must be above zero");
    
    IERC1155 nft = IERC1155(nftAddress);

    require(nft.isApprovedForAll(msg.sender, address(this)), "1006, Not approved for marketplace");
    
    listings[nftAddress][tokenId] = Listing(price, msg.sender);

    // add nft contract address and tokenId to store
    IStore(store).addTokenId(nftAddress, tokenId);

    emit ItemListed(msg.sender, nftAddress, tokenId, price);
  }

  function cancelListing(
    address nftAddress, uint256 tokenId
  ) external isListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) {
    delete listings[nftAddress][tokenId];

    // remove tokenId in contract tokenId set
    IStore(store).removeTokenId(nftAddress, tokenId);

    emit ItemCanceled(msg.sender, nftAddress, tokenId);
  }

  function buyItem(
    address nftAddress,
    uint256 tokenId
  )
    external
    payable
    isListed(nftAddress, tokenId)
    nonReentrant
  {
    Listing memory listedItem = listings[nftAddress][tokenId];

    require(msg.value * 1000 == listedItem.price * (1000 + fee), "1003, Price not met");

    IERC1155 nft = IERC1155(nftAddress);

    require(nft.isApprovedForAll(listedItem.seller, address(this)), "1006, Not approved for marketplace");
    
    delete listings[nftAddress][tokenId];

    IERC1155(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId, 1, "");

    // remove tokenId in contract tokenId set
    IStore(store).removeTokenId(nftAddress, tokenId);

    // send value to seller directly
    uint256 serviceFee = msg.value - listedItem.price;
    (bool successOfSendToSeller, ) = payable(listedItem.seller).call{value: listedItem.price}("");
    (bool successOfSendToVault, ) = payable(vault).call{value: serviceFee}("");

    require(successOfSendToSeller && successOfSendToVault, "Transfer failed");

    emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
  }

  function updateListing(
    address nftAddress,
    uint256 tokenId,
    uint256 newPrice
  ) external isListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) {
    require(newPrice > 0, "1005, Price must be above zero");

    listings[nftAddress][tokenId].price = newPrice;

    emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
  }

  function getListing(
    address nftAddress,
    uint256 tokenId
  ) external view returns (Listing memory) {
    return listings[nftAddress][tokenId];
  }

  // move to util contract
  function getListingContracts(uint256 _skip, uint256 _limit) public view returns(address[] memory) {
    return IStore(store).getContracts(_skip, _limit);
  }

  function getListingTokenIdsOfContract(address _contract, uint256 _skip, uint256 _limit) public view returns (Listing[] memory) {
    uint256[] memory tokenIds = IStore(store).getTokenIds(_contract, _skip, _limit);

    Listing[] memory listingTokenIds = new Listing[](tokenIds.length);

    for (uint256 i = 0; i < tokenIds.length; i++) {
      listingTokenIds[i] = this.getListing(_contract, tokenIds[i]);
    }

    return listingTokenIds;
  }
}
