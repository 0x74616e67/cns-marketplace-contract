// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IStore {
  event AddTokenId(address indexed contractAddr, uint256 indexed tokenId, address indexed senderAddr);
  event RemoveTokenId(address indexed contractAddr, uint256 indexed tokenId, address indexed senderAddr);

  function addTokenId(address _contract, uint256 _tokenId) external;
  function removeTokenId(address _contract, uint256 _tokenId) external;
  function getTokenIds(address _contract, uint256 _skip, uint256 _limit) external view returns (uint256[] memory);
  function getTokenIdsAmount(address _contract) external view returns (uint256);
}