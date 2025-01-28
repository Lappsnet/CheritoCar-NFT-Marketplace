// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Auction is ReentrancyGuard {
    struct AuctionDetails {
        address seller;
        uint256 startPrice;
        uint256 startTime;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(address => mapping(uint256 => AuctionDetails)) public auctions;

    event AuctionCreated(address indexed nft, uint256 tokenId, uint256 startPrice);
    event BidPlaced(address indexed nft, uint256 tokenId, address bidder, uint256 amount);
    event AuctionSettled(address indexed nft, uint256 tokenId, address winner);

    function createAuction(
        address nft,
        uint256 tokenId,
        uint256 startPrice,
        uint256 duration
    ) external {
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        auctions[nft][tokenId] = AuctionDetails({
            seller: msg.sender,
            startPrice: startPrice,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            highestBidder: address(0),
            highestBid: 0
        });
        emit AuctionCreated(nft, tokenId, startPrice);
    }

    function placeBid(address nft, uint256 tokenId) external payable nonReentrant {
        AuctionDetails storage auction = auctions[nft][tokenId];
        require(block.timestamp < auction.endTime, "Auction ended");
        require(msg.value > auction.highestBid, "Bid too low");

        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        emit BidPlaced(nft, tokenId, msg.sender, msg.value);
    }

    function settleAuction(address nft, uint256 tokenId) external nonReentrant {
        AuctionDetails memory auction = auctions[nft][tokenId];
        require(block.timestamp >= auction.endTime, "Auction ongoing");

        if (auction.highestBidder != address(0)) {
            IERC721(nft).transferFrom(address(this), auction.highestBidder, tokenId);
            payable(auction.seller).transfer(auction.highestBid);
        } else {
            IERC721(nft).transferFrom(address(this), auction.seller, tokenId);
        }

        delete auctions[nft][tokenId];
        emit AuctionSettled(nft, tokenId, auction.highestBidder);
    }
}