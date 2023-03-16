// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@web3identity/cns-contracts/contracts/utils/Namehash.sol";

// used in cns marketplace contract
struct Listing {
    uint256 price;
    address seller;
}

// used to display in frontend
struct Name {
    uint256 price;
    address seller;
    uint256 tokenId;
    string name;
}

interface ICNSMarketplace {
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory);
}

interface IStore {
    function getContracts(uint256 _skip, uint256 _limit) external view returns (address[] memory);
    function getContractsAmount() external view returns (uint256);
    function getTokenIds(address _contract, uint256 _skip, uint256 _limit) external view returns (uint256[] memory);
    function getTokenIdsAmount(address _contract) external view returns (uint256);
}

interface IBaseRegistrar {
    // Returns the expiration timestamp of the specified label hash.
    function nameExpires(uint256 id) external view returns (uint256);
}

interface INameWrapper {
    function names(bytes32) external view returns (bytes memory);
    function userDomains(address user) external view returns (string[] memory);
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

    function setnamewrapper(address _namewrapper) public onlyOwner {
        namewrapper = _namewrapper;
    }

    function getListingContracts(uint256 _skip, uint256 _limit) public view returns(address[] memory) {
        return IStore(store).getContracts(_skip, _limit);
    }

    function getListingTokenIdsOfContract(address _contract, uint256 _skip, uint256 _limit) public view returns (Name[] memory) {
        uint256[] memory tokenIds = IStore(store).getTokenIds(_contract, _skip, _limit);

        Name[] memory names = new Name[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            // get listing info
            Listing memory l = ICNSMarketplace(CNSMarketplace).getListing(_contract, tokenIds[i]);
            // get name from tokenId
            bytes memory name = INameWrapper(namewrapper).names(bytes32(tokenIds[i]));
            names[i] = Name(l.price, l.seller, tokenIds[i], string(name));
        }

        return names;
    }

    function getListingTokenIdsOfContractAmount(address _contract) public view returns (uint256) {
        return IStore(store).getTokenIdsAmount(_contract);
    }

    function getOwnedNames(address owner) public view returns (Name[] memory) {
        // get domain tokenIds of owner
        bytes32[] memory tokenIds = INameWrapper(namewrapper).userNodeSet(owner);

        Name[] memory names = new Name[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = uint256(tokenIds[i]);

            bytes memory name = INameWrapper(namewrapper).names(bytes32(tokenId));

            Listing memory l = ICNSMarketplace(CNSMarketplace).getListing(namewrapper, tokenId);

            names[i] = Name(l.price, l.seller, tokenId, string(name));
        }

        return names;
    }
}