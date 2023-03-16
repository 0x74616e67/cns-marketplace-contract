// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Store is AccessControl {
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;

  bytes32 public constant ROLE_CALL = keccak256("CALL");

  EnumerableSet.AddressSet private contracts;

  mapping(address => EnumerableSet.UintSet) private tokenIds;

  // error ContractIsAlreadyExist(address contractAddr);
  // error ContractIsNotExist(address contractAddr);
  // error TokenIsAlreadyExist(address contractAddr, uint256 tokenId);
  // error TokenIsNotExist(address contractAddr, uint256 tokenId);
  // error NumberIsLessThanZero(uint256 number);
  // error SkipNumberIsExceedTotalNunber(uint256 skipNumber, uint256 totalNumber);
  // error AddressIsNotContract(address contractAdddr);

  // Error code:
  // 1001, Contract is already exist
  // 1002, Contract is not exist
  // 1003, Token is already exist
  // 1004, Token is not exist
  // 1005, Number is less than zero
  // 1006, Skip number is exceed total nunber
  // 1007, Address is not contract

  event AddContract(
    address indexed contractAddr,
    address indexed senderAddr
  );

  event RemoveContract(
    address indexed contractAddr,
    address indexed senderAddr
  );

  event AddTokenId(
    address indexed contractAddr,
    uint256 indexed tokenId,
    address indexed senderAddr
  );
  
  event RemoveTokenId(
    address indexed contractAddr,
    uint256 indexed tokenId,
    address indexed senderAddr
  );

  modifier isContractInStore (address _contract) {
    require(contracts.contains(_contract), "1002, Contract is not exist");

    _;
  }

  modifier isTokenIdInContract (address _contract, uint256 _tokenId) {
    require(tokenIds[_contract].contains(_tokenId), "1004, Token is not exist");

    _;
  }

  modifier isTokenIdNotInContract (address _contract, uint256 _tokenId) {
    require(!tokenIds[_contract].contains(_tokenId), "1003, Token is already exist");

    _;
  }

  modifier  isGteZero(uint256 _number) {
    require(_number >= 0, "1005, Number is less than zero");
      
    _;
  }

  modifier  isContract(address _contract) {
    require(_contract.code.length > 0, "1007, Address is not contract");

    _;
  }

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ROLE_CALL, msg.sender);
  }

  // function addContract(address _contract) public isContract(_contract) {
  function addContract(address _contract) public onlyRole(ROLE_CALL) {
    require(!contracts.contains(_contract), "1001, Contract is already exist");

    contracts.add(_contract);

    emit AddContract(_contract, msg.sender);
  }

  function removeContract(address _contract) public isContractInStore(_contract) onlyRole(ROLE_CALL) {
    contracts.remove(_contract);

    emit RemoveContract(_contract, msg.sender);
  }

  function getContracts(uint256 _skip, uint256 _limit) 
    public 
    view 
    onlyRole(ROLE_CALL) 
    isGteZero(_skip)
    isGteZero(_limit)
    returns (address[] memory) 
  {
    uint256 len = contracts.length();

    require(_skip <= len, "1006, Skip number is exceed total nunber");

    uint256 limit = len - _skip > _limit ? _limit : len - _skip;

    address[] memory list = new address[](limit);

    for (uint256 i = 0; i < limit; i++) {
        list[i] = contracts.at(_skip + i);
    }

    return list;
  }

  function getContractsAmount() public view returns (uint256) {
    return contracts.length();
  }

  function addTokenId(
    address _contract, 
    uint256 _tokenId
  ) 
    public 
    onlyRole(ROLE_CALL) 
  {
    if (!contracts.contains(_contract)) {
      this.addContract(_contract);
    }
  
    EnumerableSet.UintSet storage tokenIdSet = tokenIds[_contract];

    require(!tokenIdSet.contains(_tokenId), "1003, Token is already exist");

    tokenIdSet.add(_tokenId);

    emit AddTokenId(_contract, _tokenId, msg.sender);
  }

  function removeTokenId(address _contract, uint256 _tokenId) 
    public 
    isContractInStore(_contract) 
    isTokenIdInContract(_contract, _tokenId)
    onlyRole(ROLE_CALL) 
  {
      EnumerableSet.UintSet storage tokenIdSet = tokenIds[_contract];

      tokenIdSet.remove(_tokenId);

      if (tokenIdSet.length() == 0) {
        this.removeContract(_contract);
      }

      emit RemoveTokenId(_contract, _tokenId, msg.sender);
  }

  function getTokenIds(address _contract, uint256 _skip, uint256 _limit) 
    public 
    view 
    onlyRole(ROLE_CALL) 
    isContractInStore(_contract) 
    isGteZero(_skip)
    isGteZero(_limit)
    returns (uint256[] memory) 
  {
    EnumerableSet.UintSet storage tokenIdSet = tokenIds[_contract];
    
    uint256 len = tokenIdSet.length();

    require(_skip <= len, "1006, Skip number is exceed total nunber");

    uint256 limit = len - _skip > _limit ? _limit : len - _skip;

    uint256[] memory list = new uint256[](limit);

    for (uint256 i = 0; i < limit; i++) {
        list[i] = tokenIdSet.at(_skip + i);
    }

    return list;
  }

  function getTokenIdsAmount(address _contract)
    public 
    view 
    isContractInStore(_contract) 
    returns (uint256) 
  {
    EnumerableSet.UintSet storage tokenIdSet = tokenIds[_contract];
    return tokenIdSet.length();
  }
}