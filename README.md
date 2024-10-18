NFT Marketplace Smart Contract
This smart contract allows users to mint their own NFTs, create auctions, and bid on NFTs. It is built using Solidity and uses the OpenZeppelin ERC721 standard for NFTs. Users can start auctions for their NFTs, set a starting price, and bidders can place bids. At the end of the auction, the highest bidder wins, and the NFT is transferred to them, while other bidders get their funds refunded.

Features
Mint Your Own NFTs: Users can mint their own NFTs by providing a tokenURI (metadata link) for the NFT.
Start Auctions: NFT owners can start auctions by setting a starting price.
Bid on NFTs: Users can place bids on active auctions, with higher bids overriding the previous ones.
End Auctions: The auction ends when the set duration expires, and the highest bidder receives the NFT.
Refund Mechanism: Non-winning bidders get their funds refunded when the auction ends.
Prerequisites
Solidity Version: ^0.8.0
OpenZeppelin Contracts:
ERC721
ERC721URIStorage
Ownable
Installation
Install Node.js and npm (if not already installed).
Set up the environment by installing the OpenZeppelin contracts:
bash
Copy code
npm install @openzeppelin/contracts
Use Remix or Hardhat for deployment.
Smart Contract Explanation
Contract Files
1. NFTMarketplace.sol
This is the core contract that implements the NFT marketplace functionality, allowing users to mint, start auctions, bid, and end auctions.

Functions
1. Constructor
The constructor initializes the NFT contract with a default name and symbol for the NFT collection.

solidity
Copy code
constructor() ERC721("DefaultNFT", "DNFT") Ownable(msg.sender) {}
ERC721("DefaultNFT", "DNFT"): Sets the default name as "DefaultNFT" and symbol as "DNFT".
Ownable(msg.sender): Assigns the deployer of the contract as the owner.
2. mintNFT
This function allows users to mint a new NFT. The tokenURI provided by the user links to the metadata of the NFT (e.g., name, description, image, and attributes).

solidity
Copy code
function mintNFT(string memory _tokenURI) public returns (uint)
Arguments:
_tokenURI: The URI containing metadata of the NFT.
Returns:
tokenId: The unique identifier of the minted NFT.
Emits:
NFTMinted: Event emitted when a new NFT is minted.
3. startAuction
This function allows the NFT owner to start an auction for a specific NFT, providing a starting price and auction duration.

solidity
Copy code
function startAuction(uint _tokenId, uint _startingPrice) public
Arguments:
_tokenId: The ID of the NFT for auction.
_startingPrice: The minimum bid required to start bidding.
Emits:
AuctionStarted: Event emitted when an auction starts.
4. placeBid
This function allows users to place bids on an active auction. The bid must be higher than the current highest bid and the starting price. If a new highest bid is placed, the previous highest bidder's funds are refunded.

solidity
Copy code
function placeBid(uint _tokenId) public payable
Arguments:
_tokenId: The ID of the NFT for bidding.
Emits:
NewBid: Event emitted when a new bid is placed.
5. endAuction
This function allows the auction to be ended when the auction duration expires. The NFT is transferred to the highest bidder, and the seller receives the funds.

solidity
Copy code
function endAuction(uint _tokenId) public
Arguments:
_tokenId: The ID of the NFT to end the auction for.
Emits:
AuctionEnded: Event emitted when an auction ends.
6. withdrawBid
Non-winning bidders can call this function to withdraw their bids once the auction ends.

solidity
Copy code
function withdrawBid(uint _tokenId) public
Arguments:
_tokenId: The ID of the NFT for which to withdraw the bid.
Events
NFTMinted: Emitted when a new NFT is minted.

creator: The address of the NFT creator.
tokenId: The ID of the newly minted NFT.
tokenURI: The URI containing metadata of the NFT.
AuctionStarted: Emitted when an auction is started.

tokenId: The ID of the NFT.
startingPrice: The price at which the auction starts.
endAt: The timestamp when the auction ends.
NewBid: Emitted when a new bid is placed.

tokenId: The ID of the NFT.
bidder: The address of the bidder.
bid: The amount bid.
AuctionEnded: Emitted when an auction is successfully ended.

tokenId: The ID of the NFT.
winner: The address of the highest bidder.
winningBid: The winning bid amount.
Usage
Minting an NFT
To mint a new NFT, call the mintNFT function with a tokenURI that points to the metadata of the NFT.

solidity
Copy code
mintNFT("https://example.com/nft/metadata/123");
Starting an Auction
To start an auction, call the startAuction function with the tokenId of the NFT and the starting price.

solidity
Copy code
startAuction(1, 1 ether); // Start auction for tokenId 1 with a starting price of 1 ETH
Placing a Bid
To place a bid, call the placeBid function with the tokenId of the NFT. The bid must be higher than the current highest bid or the starting price.

solidity
Copy code
placeBid(1); // Place a bid for tokenId 1
Ending the Auction
To end the auction after the auction duration has passed, call the endAuction function with the tokenId.

solidity
Copy code
endAuction(1); // End auction for tokenId 1
Withdrawing a Bid
To withdraw a bid (for non-winning bidders), call the withdrawBid function with the tokenId.

solidity
Copy code
withdrawBid(1); // Withdraw the bid for tokenId 1
Time Duration Example
For 3-minute auction duration:

solidity
Copy code
auction.endAt = block.timestamp + 180; // 180 seconds = 3 minutes
For 5-minute auction duration:

solidity
Copy code
auction.endAt = block.timestamp + 300; // 300 seconds = 5 minutes
License
This project is licensed under the MIT License - see the LICENSE file for details.

