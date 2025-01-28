// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./FeeManager.sol";

contract Marketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    event Listed(address indexed nft, uint256 tokenId, uint256 price);
    event Sold(address indexed nft, uint256 tokenId, address buyer);

    FeeManager public feeManager;

    constructor(address _feeManager) {
        feeManager = FeeManager(_feeManager);
    }

    function listNFT(address nft, uint256 tokenId, uint256 price) external {
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        listings[nft][tokenId] = Listing(msg.sender, price);
        emit Listed(nft, tokenId, price);
    }

    function buyNFT(address nft, uint256 tokenId) external payable nonReentrant {
        Listing memory listing = listings[nft][tokenId];
        require(msg.value >= listing.price, "Insufficient funds");

        uint256 fee = feeManager.calculateFee(msg.value);
        uint256 sellerProceeds = msg.value - fee;

        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
        payable(listing.seller).transfer(sellerProceeds);
        delete listings[nft][tokenId];

        emit Sold(nft, tokenId, msg.sender);
    }

    function withdrawFees() external {
        require(msg.sender == feeManager.feeRecipient(), "Unauthorized");
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
