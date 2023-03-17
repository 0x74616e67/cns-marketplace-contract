// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IStore {
  function addTokenId(uint256 _tokenId) external;
  function removeTokenId(uint256 _tokenId) external;
}

// error NotListed(uint256 tokenId);
// error AlreadyListed(uint256 tokenId);
// error PriceNotMet(uint256 tokenId, uint256 price);
// error NotOwner();
// error PriceMustBeAboveZero(uint256);
// error NotApprovedForMarketplace();
// error FeeMustBeGreZeroAndLreOneHundred(uint256);

/**
Error Code:
1. 1001, Not listed
2. 1002, Already listed
3. 1003, Price + Fee not met
4. 1004, Not owner
5. 1005, Price must be above zero
6. 1006, Not approved to marketplace
9. 1009, Fee must be greater or equal to 0, and less or equal to 1000
*/

contract CNSMarketplace is ReentrancyGuard, Ownable {

  // tokenIds store
  address public store;

  address public vault;

  // cns namewrapper 1155 compatible contract address
  address public namewrapper;

  // 25 / 1000
  uint8 public fee = 25;

  struct Listing {
    uint256 price;
    address seller;
  }

  event ItemListed(
    address indexed seller,
    uint256 indexed tokenId,
    uint256 price
  );

  event ItemCanceled(
    address indexed seller,
    uint256 indexed tokenId
  );

  event ItemBought(
    address indexed buyer,
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

  event UpdateNamewrapper(
    address indexed prev,
    address indexed next
  );

  event UpdateFee(
    uint8 prev,
    uint8 indexed curr
  );

  // tokenId => Listing
  mapping(uint256 => Listing) private listings;

  modifier isListed(uint256 tokenId) {
    Listing memory listing = listings[tokenId];

    require(listing.price > 0, "1001, Not listed");

    _;
  }

  modifier isNotListed(uint256 tokenId) {
    Listing memory listing = listings[tokenId];

    require(listing.price <= 0, "1002, Already listed");

    _;
  }

  modifier isOwner(
    uint256 tokenId,
    address spender
  ) {
    IERC1155 nft = IERC1155(namewrapper);
    uint256 balance = nft.balanceOf(spender, tokenId);
    
    require(balance > 0, "1004, Not owner");
    
    _;
  }

  constructor(address _store, address _vault, address _namewrapper) {
      store = _store;
      vault = _vault;
      namewrapper = _namewrapper;
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

  function updateNamewrapper(address _namewrapper) public onlyOwner {
    address prev = namewrapper;
    namewrapper = _namewrapper;

    emit UpdateNamewrapper(prev, _namewrapper);
  }

  function updateFee(uint8 _fee) public onlyOwner {
    require(fee >= 0 && fee <= 1000, "1009, Fee must be greater or equal to 0, and less or equal to 1000");
    
    uint8 prev = fee;
    fee = _fee;

    emit UpdateFee(prev, fee);
  }

  function listItem(
    uint256 tokenId,
    uint256 price
  ) public isNotListed(tokenId) isOwner(tokenId, msg.sender) {
    require(price > 0, "1005, Price must be above zero");
    
    IERC1155 nft = IERC1155(namewrapper);

    require(nft.isApprovedForAll(msg.sender, address(this)), "1006, Not approved to marketplace");
    
    listings[tokenId] = Listing(price, msg.sender);

    // add nft tokenId to store
    IStore(store).addTokenId(tokenId);

    emit ItemListed(msg.sender, tokenId, price);
  }

  function cancelListing(
    uint256 tokenId
  ) public isListed(tokenId) isOwner(tokenId, msg.sender) {
    delete listings[tokenId];

    // remove tokenId in contract tokenId set
    IStore(store).removeTokenId(tokenId);

    emit ItemCanceled(msg.sender, tokenId);
  }

  function buyItem(
    uint256 tokenId
  )
    public
    payable
    isListed(tokenId)
    nonReentrant
  {
    Listing memory listedItem = listings[tokenId];

    require(msg.value * 1000 == listedItem.price * (1000 + fee), "1003, Price + Fee not met");

    IERC1155 nft = IERC1155(namewrapper);

    require(nft.isApprovedForAll(listedItem.seller, address(this)), "1006, Not approved to marketplace");
    
    delete listings[tokenId];

    // remove tokenId in contract tokenId set
    IStore(store).removeTokenId(tokenId);

    IERC1155(namewrapper).safeTransferFrom(listedItem.seller, msg.sender, tokenId, 1, "");

    // send value to seller directly
    uint256 serviceFee = msg.value - listedItem.price;
    (bool successOfSendToSeller, ) = payable(listedItem.seller).call{value: listedItem.price}("");
    (bool successOfSendToVault, ) = payable(vault).call{value: serviceFee}("");

    require(successOfSendToSeller && successOfSendToVault, "Transfer failed");

    emit ItemBought(msg.sender, tokenId, listedItem.price);
  }

  function updateListing(
    uint256 tokenId,
    uint256 newPrice
  ) public isListed(tokenId) isOwner(tokenId, msg.sender) {
    require(newPrice > 0, "1005, Price must be above zero");

    listings[tokenId].price = newPrice;

    emit ItemListed(msg.sender, tokenId, newPrice);
  }

  function getListing(
    uint256 tokenId
  ) public view returns (Listing memory) {
    return listings[tokenId];
  }
}
