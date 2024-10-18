// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarketplace is ERC721URIStorage, Ownable, ReentrancyGuard {

    uint public tokenIdCounter = 0; // Counter for NFTs

    struct Auction {
        address payable seller;
        uint startingPrice;
        uint highestBid;
        address highestBidder;
        uint endAt;
        bool isAuctionActive;
        bool isAuctionEnded;
        mapping(address => uint) bids; // Tracks each bidder's bid
    }

    mapping(uint => Auction) public auctions; // Auction details per NFT (tokenId)
    mapping(uint => string) public nftNames; // Store names for each tokenId
    mapping(uint => string) public nftSymbols; // Store symbols for each tokenId

    event NFTMinted(address indexed creator, uint tokenId, string tokenURI, string name, string symbol);
    event AuctionStarted(uint tokenId, uint startingPrice, uint endAt);
    event NewBid(uint tokenId, address bidder, uint bid);
    event AuctionEnded(uint tokenId, address winner, uint winningBid);
    
    // Constructor: Set contract owner
   constructor() ERC721("DefaultNFT", "DNFT") Ownable(msg.sender) {}


    // Mint an NFT with a custom name and symbol
    function mintNFT(string memory _tokenURI, string memory _name, string memory _symbol) public returns (uint) {
        uint tokenId = tokenIdCounter;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        
        // Store custom name and symbol for the NFT
        nftNames[tokenId] = _name;
        nftSymbols[tokenId] = _symbol;

        emit NFTMinted(msg.sender, tokenId, _tokenURI, _name, _symbol);

        tokenIdCounter++;
        return tokenId;
    }

    // Start an auction for an NFT
    function startAuction(uint _tokenId, uint _startingPrice) public {
        require(ownerOf(_tokenId) == msg.sender, "Only owner can start auction");
        require(!auctions[_tokenId].isAuctionActive, "Auction already active");

        Auction storage auction = auctions[_tokenId];
        auction.seller = payable(msg.sender);
        auction.startingPrice = _startingPrice;
        auction.highestBid = 0;
        auction.highestBidder = address(0);
      auction.endAt = block.timestamp + 180; // Set auction duration to 3 minutes

        auction.isAuctionActive = true;
        auction.isAuctionEnded = false;

        emit AuctionStarted(_tokenId, _startingPrice, auction.endAt);
    }

    // Place a bid on an active auction
    function placeBid(uint _tokenId) public payable nonReentrant {
        Auction storage auction = auctions[_tokenId];
        require(auction.isAuctionActive, "Auction is not active");
        require(block.timestamp < auction.endAt, "Auction ended");
        require(msg.value > auction.highestBid && msg.value > auction.startingPrice, "Bid too low");

        // Refund the previous highest bidder
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        auction.bids[msg.sender] = msg.value;

        emit NewBid(_tokenId, msg.sender, msg.value);
    }

    // End the auction and transfer the NFT
    function endAuction(uint _tokenId) public nonReentrant {
        Auction storage auction = auctions[_tokenId];
        require(auction.isAuctionActive, "Auction is not active");
        require(block.timestamp >= auction.endAt, "Auction not ended yet");

        auction.isAuctionActive = false;
        auction.isAuctionEnded = true;

        if (auction.highestBidder != address(0)) {
            // Transfer NFT to the highest bidder
            _transfer(auction.seller, auction.highestBidder, _tokenId);
            // Transfer the highest bid to the seller
            auction.seller.transfer(auction.highestBid);
            
            emit AuctionEnded(_tokenId, auction.highestBidder, auction.highestBid);
        } else {
            // If no bids, the auction ends without a sale
            auction.isAuctionEnded = true;
        }
    }

    // Allow users to withdraw funds if their bid didn't win
    function withdrawBid(uint _tokenId) public nonReentrant {
        Auction storage auction = auctions[_tokenId];
        require(auction.isAuctionEnded, "Auction not ended");
        require(msg.sender != auction.highestBidder, "Winner can't withdraw");

        uint bidAmount = auction.bids[msg.sender];
        require(bidAmount > 0, "No bid to withdraw");

        auction.bids[msg.sender] = 0;
        payable(msg.sender).transfer(bidAmount);
    }
}
