// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    uint256 private _priceInWei;
    uint256 private _maxSupply;

    constructor(address initialOwner, uint256 _supply)
        ERC721("SolidityDev", "SD")
        Ownable(initialOwner)
    {
        _maxSupply = _supply;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmPMc4tcBsMqLRuCQtPmPe84bpSjrC3Ky7t3JWuHXYB4aS/";
    }

    function safeMint(address to) public onlyOwner {
        require(_nextTokenId < _maxSupply, "max supply reached");
        require(super.balanceOf(to)==0, "user already have NFT");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function buy() public payable {
        require(_nextTokenId < _maxSupply, "max supply reached");
        require(super.balanceOf(msg.sender)==0, "user already have NFT");

        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "nothing to withdraw");
        payable(owner()).transfer(balance);
    }
}