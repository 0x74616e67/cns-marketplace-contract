// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@web3identity/cns-contracts/contracts/utils/Namehash.sol";

struct Listing {
    uint256 price;
    address seller;
}

struct Name {
    uint256 price;
    address seller;
    uint256 tokenId;
    string name;
}

interface ICNSMarketplace {
    function getListing(uint256 tokenId) external view returns (Listing memory);
}

interface IStore {
    function getTokenIds(uint256 _skip, uint256 _limit) external view returns (uint256[] memory);
    function getTokenIdsAmount() external view returns (uint256);
}

interface INameWrapper {
    function names(bytes32) external view returns (bytes memory);
    function userNodeSet(address user) external view returns (bytes32[] memory);
}

contract CNSUtils is Ownable{
    address public store;
    address public CNSMarketplace;
    address public namewrapper;

    constructor(address _store, address _CNSMarketplace, address _namewrapper) {
        store = _store;
        CNSMarketplace = _CNSMarketplace;
        namewrapper = _namewrapper;
    }

    function setStore(address _store) public onlyOwner {
        store = _store;
    }

    function setCNSMarketplace(address _CNSMarketplace) public onlyOwner {
        CNSMarketplace = _CNSMarketplace;
    }

    function setNamewrapper(address _namewrapper) public onlyOwner {
        namewrapper = _namewrapper;
    }

    function getListingNames(uint256 _skip, uint256 _limit) public view returns (Name[] memory) {
        uint256[] memory tokenIds = IStore(store).getTokenIds(_skip, _limit);

        Name[] memory names = new Name[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            Listing memory l = ICNSMarketplace(CNSMarketplace).getListing(tokenIds[i]);
            bytes memory name = INameWrapper(namewrapper).names(bytes32(tokenIds[i]));
            names[i] = Name(l.price, l.seller, tokenIds[i], string(name));
        }

        return names;
    }

    function getListingNamesAmount() public view returns (uint256) {
        return IStore(store).getTokenIdsAmount();
    }

    function getOwnedNames(address owner) public view returns (Name[] memory) {
        bytes32[] memory tokenIds = INameWrapper(namewrapper).userNodeSet(owner);

        Name[] memory names = new Name[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = uint256(tokenIds[i]);

            bytes memory name = INameWrapper(namewrapper).names(bytes32(tokenId));

            Listing memory l = ICNSMarketplace(CNSMarketplace).getListing(tokenId);

            names[i] = Name(l.price, l.seller, tokenId, string(name));
        }

        return names;
    }
}