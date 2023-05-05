# RoyaltyShareNFT

RoyaltyShareNFT is a decentralized application built on Ethereum that allows artists to sell NFTs of their artwork and receive royalties whenever the artwork is used. The NFTs are minted with a specific price, and the buyer can use the NFT for a certain number of days by paying the appropriate fee.
## Table of Contents 
- [Contract Overview](#contract-overview) 
- [Setup and Installation](#setup-and-installation) 
- [Usage](#usage)  
- [Testing on Remix](h#testing-on-remix) 
- [Functions](#functions)  
- [Constructor](#constructor) 
- [mintImage](#mintimage) 
- [useImage](#useimage) 
- [createTrade](#createtrade) 
- [acceptTrade](#accepttrade) 
- [cancelTrade](#canceltrade) 
- [makePriceSuggestion](#makepricesuggestion) 
- [acceptPriceSuggestion](#acceptpricesuggestion)
## Contract Overview

The smart contract includes the following key features:
1. Minting NFTs with a specific price and royalty rate.
2. Using NFTs for a certain number of days by paying the appropriate fee.
3. Creating, accepting, and canceling trades between buyers and sellers.
4. Suggesting and accepting price changes for the NFTs.
## Setup and Installation
1. Clone the repository:

```bash

git clone https://github.com/graftim/RoyaltyShareNFT.git
```

## Usage
### Testing on Remix

To test the smart contract on Remix, follow these steps: 
1. Visit the [Remix Ethereum IDE](https://remix.ethereum.org/) . 
2. Create a new Solidity file and copy the entire contents of the `RoyaltyShareNFT.sol` contract into the new file.
3. Compile the smart contract by clicking the "Compile" button.
4. Switch to the "Deploy & Run Transactions" tab.
5. Select the "Injected Provider - Metamask" environment to connect to MetaMask.
6. Deploy the smart contract with the necessary constructor parameters (name, symbol, and whitepaperURI).
7. Interact with the deployed smart contract using the provided functions in the Deploy & run transactions tab.
## Base Functions
### Constructor

```solidity

constructor(string memory name, string memory symbol, string memory _whitepaperURI)
```



Initializes the contract with the given name, symbol, and whitepaper URI.
### mintImage

```solidity

function mintImage(address artist, address buyer, string memory uri, uint256 royaltyRate, uint256 price) external onlyOwner returns (uint256)
```

Mints a new NFT with the given artist address, buyer address, URI, royalty rate, and price. Only the contract owner (Marketplace) can call this function. Due to legal restrictions, the NFT is directly granted to the buyer, and the NFT references to the artists address. The royalty rate is the percentage the artist keeps in basis points (between 0 and 10000). The price is the price of the NFT in wei.
### useImage

```solidity

function useImage(uint256 tokenId, uint256 n_days) external payable
```

Allows a user to use the NFT for a certain number of days by paying the appropriate fee. The total fee is calculated by multiplying the NFT price by the number of days.
The fee is then split between the artist and the NFT holder. The artist receives the royalty rate percentage of the fee, and the NFT holder receives the remaining percentage of the fee. 


## Trade Functions
These functions are used to create, accept, and cancel trades between buyers and sellers. This allows for a trade to be done with zero trust, as it only exectutes when both buyer and seller agree.

### createTrade

```solidity

function createTrade(uint256 tokenId, address payable buyer, uint256 price) external
```

Creates a new trade for the given NFT (tokenId) with the specified buyer and price. Only the token owner can create a trade.
### acceptTrade

```solidity

function acceptTrade(uint256 tokenId) external payable
```

Accepts the trade for the given NFT (tokenId). Only the buyer can accept the trade. Upon acceptance, the NFT is transferred to the buyer and the payment is transferred to the seller. The trade is then marked as inactive.
### cancelTrade

```solidity

function cancelTrade(uint256 tokenId) external
```


Cancels the trade for the given tokenId. Only the seller can cancel the trade. The trade is then marked as inactive.

## Price Suggestion Functions
These functions are used to set a different price for the useImage function. The price can only be changed if both the creator and token holder agree on the new price.
### makePriceSuggestion

```solidity

function makePriceSuggestion(uint256 tokenId, uint256 newPrice) external
```

Allows the creator or token holder to make a price suggestion for the NFT. The suggested new price must be greater than 0.
### acceptPriceSuggestion

```solidity

function acceptPriceSuggestion(uint256 tokenId) external
```

Allows the other party (creator or token holder) to accept the price suggestion for the NFT. Upon acceptance, the price of the NFT is updated and the price suggestion is deleted.
