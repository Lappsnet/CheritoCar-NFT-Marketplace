// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    event Listed(address indexed nft, uint256 tokenId, uint256 price);
    event Sold(address indexed nft, uint256 tokenId, address buyer);

    function listNFT(address nft, uint256 tokenId, uint256 price) external {
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        listings[nft][tokenId] = Listing(msg.sender, price);
        emit Listed(nft, tokenId, price);
    }

    function buyNFT(address nft, uint256 tokenId) external payable nonReentrant {
        Listing memory listing = listings[nft][tokenId];
        require(msg.value >= listing.price, "Insufficient funds");
        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
        payable(listing.seller).transfer(msg.value);
        delete listings[nft][tokenId];
        emit Sold(nft, tokenId, msg.sender);
    }
}