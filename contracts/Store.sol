// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Store is AccessControl {
  using EnumerableSet for EnumerableSet.UintSet;

  bytes32 public constant ROLE_CALL = keccak256("CALL");

  EnumerableSet.UintSet private tokenIds;

  // error TokenIsAlreadyExist(address contractAddr, uint256 tokenId);
  // error TokenIsNotExist(address contractAddr, uint256 tokenId);
  // error NumberIsLessThanZero(uint256 number);
  // error SkipNumberIsExceedTotalNunber(uint256 skipNumber, uint256 totalNumber);

  // Error code:
  // 1003, Token is already exist
  // 1004, Token is not exist
  // 1005, Number is less than zero
  // 1006, Skip number is exceed total nunber

  event AddTokenId(
    uint256 indexed tokenId,
    address indexed sender
  );
  
  event RemoveTokenId(
    uint256 indexed tokenId,
    address indexed sender
  );

  modifier isTokenIdExist (uint256 _tokenId) {
    require(tokenIds.contains(_tokenId), "1004, Token is not exist");

    _;
  }

  modifier isTokenIdNotExist (uint256 _tokenId) {
    require(!tokenIds.contains(_tokenId), "1003, Token is already exist");

    _;
  }

  modifier  isGteZero(uint256 _number) {
    require(_number >= 0, "1005, Number is less than zero");
      
    _;
  }

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ROLE_CALL, msg.sender);
    _setupRole(ROLE_CALL, address(this));
  }

  function addTokenId(uint256 _tokenId) 
    public 
    isTokenIdNotExist(_tokenId)
    onlyRole(ROLE_CALL) 
  {
    tokenIds.add(_tokenId);

    emit AddTokenId(_tokenId, msg.sender);
  }

  function removeTokenId(uint256 _tokenId) 
    public 
    isTokenIdExist(_tokenId)
    onlyRole(ROLE_CALL) 
  {
      tokenIds.remove(_tokenId);

      emit RemoveTokenId(_tokenId, msg.sender);
  }

  function getTokenIds(uint256 _skip, uint256 _limit) 
    public 
    view 
    isGteZero(_skip)
    isGteZero(_limit)
    onlyRole(ROLE_CALL) 
    returns (uint256[] memory) 
  { 
    uint256 len = tokenIds.length();

    require(_skip <= len, "1006, Skip number is exceed total nunber");

    uint256 limit = len - _skip > _limit ? _limit : len - _skip;

    uint256[] memory list = new uint256[](limit);

    for (uint256 i = 0; i < limit; i++) {
        list[i] = tokenIds.at(_skip + i);
    }

    return list;
  }

  function getTokenIdsAmount()
    public 
    view 
    returns (uint256) 
  {
    return tokenIds.length();
  }
}