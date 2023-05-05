// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoyaltyShareNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public whitepaperURI;

    struct Artwork {
        string uri;
        uint256 royaltyRate; // Percentage in basis points (1 basis point = 0.01%)
        address creator;
        uint256 price;
    }

    struct Trade {
        uint256 tokenId;
        address payable seller;
        address payable buyer;
        uint256 price;
        bool active;
    }

    struct PriceSuggestion {
        address suggester;
        uint256 newPrice;
    }

    mapping(uint256 => Artwork) public artworks;
    mapping(uint256 => Trade) public trades;
    mapping(uint256 => PriceSuggestion) public priceSuggestions;

    event ArtworkUsed(uint256 indexed tokenId);
    event TradeCreated(uint256 indexed tradeId);
    event TradeAccepted(uint256 indexed tradeId);
    event TradeCancelled(uint256 indexed tradeId);

    constructor(
        string memory name,
        string memory symbol,
        string memory _whitepaperURI
    ) ERC721(name, symbol) {
        whitepaperURI = _whitepaperURI;
    }

    function mintImage(
        address artist,
        address buyer,
        string memory uri,
        uint256 royaltyRate,
        uint256 price
    ) external onlyOwner returns (uint256) {
        require(
            royaltyRate <= 10000,
            "Royalty rate should be less than or equal to 10000 basis points."
        );

        _tokenIds.increment();
        uint256 newArtworkId = _tokenIds.current();
        _mint(buyer, newArtworkId);

        Artwork memory newArtwork = Artwork({
            uri: uri,
            royaltyRate: royaltyRate,
            creator: artist,
            price: price
        });

        artworks[newArtworkId] = newArtwork;
        return newArtworkId;
    }

    function useImage(uint256 tokenId, uint256 n_days) external payable {
        require(_exists(tokenId), "RoyaltyShareNFT: Invalid token ID.");
        require(
            n_days > 0,
            "RoyaltyShareNFT: Number of days must be greater than 0."
        );
        uint256 totalPrice = artworks[tokenId].price * n_days;
        require(
            msg.value == totalPrice,
            "RoyaltyShareNFT: Sent value must be equal to the NFT price multiplied by the number of days."
        );

        address creator = artworks[tokenId].creator;
        uint256 creatorRoyalty = (totalPrice * artworks[tokenId].royaltyRate) /
            10000;
        uint256 ownerRoyalty = totalPrice - creatorRoyalty;

        // Pay royalties
        payable(creator).transfer(creatorRoyalty);
        payable(ownerOf(tokenId)).transfer(ownerRoyalty);

        emit ArtworkUsed(tokenId);
    }

    function createTrade(
        uint256 tokenId,
        address payable buyer,
        uint256 price
    ) external {
        require(_exists(tokenId), "RoyaltyShareNFT: Invalid token ID.");
        require(
            ownerOf(tokenId) == msg.sender,
            "RoyaltyShareNFT: Only the token owner can create a trade."
        );
        require(price > 0, "RoyaltyShareNFT: Price must be greater than 0.");

        Trade memory newTrade = Trade({
            tokenId: tokenId,
            seller: payable(msg.sender),
            buyer: buyer,
            price: price,
            active: true
        });

        trades[tokenId] = newTrade;
        emit TradeCreated(tokenId);
    }

    function acceptTrade(uint256 tokenId) external payable {
        require(trades[tokenId].active, "RoyaltyShareNFT: Trade not active.");
        require(
            trades[tokenId].buyer == msg.sender,
            "RoyaltyShareNFT: Only the buyer can accept the trade."
        );
        require(
            msg.value == trades[tokenId].price,
            "RoyaltyShareNFT: Sent value must be equal to the trade price."
        );

        // Transfer NFT
        _transfer(trades[tokenId].seller, trades[tokenId].buyer, tokenId);

        // Transfer ETH to the seller
        trades[tokenId].seller.transfer(msg.value);

        // Mark trade as inactive
        trades[tokenId].active = false;

        emit TradeAccepted(tokenId);
    }

    function cancelTrade(uint256 tokenId) external {
        require(trades[tokenId].active, "RoyaltyShareNFT: Trade not active.");
        require(
            trades[tokenId].seller == msg.sender,
            "RoyaltyShareNFT: Only the seller can cancel the trade."
        );

        trades[tokenId].active = false;
        emit TradeCancelled(tokenId);
    }

    function makePriceSuggestion(uint256 tokenId, uint256 newPrice) external {
        require(_exists(tokenId), "RoyaltyShareNFT: Invalid token ID.");
        require(newPrice > 0, "RoyaltyShareNFT: Price must be greater than 0.");
        address suggester = msg.sender;
        require(
            artworks[tokenId].creator == suggester ||
                ownerOf(tokenId) == suggester,
            "RoyaltyShareNFT: Only the creator or token holder can make a price suggestion."
        );

        PriceSuggestion memory newPriceSuggestion = PriceSuggestion({
            suggester: suggester,
            newPrice: newPrice
        });

        priceSuggestions[tokenId] = newPriceSuggestion;
    }

    function acceptPriceSuggestion(uint256 tokenId) external {
        require(_exists(tokenId), "RoyaltyShareNFT: Invalid token ID.");
        require(
            priceSuggestions[tokenId].suggester != address(0),
            "RoyaltyShareNFT: No price suggestion for this token."
        );
        require(
            (artworks[tokenId].creator == msg.sender &&
                ownerOf(tokenId) == priceSuggestions[tokenId].suggester) ||
                (ownerOf(tokenId) == msg.sender &&
                    artworks[tokenId].creator ==
                    priceSuggestions[tokenId].suggester),
            "RoyaltyShareNFT: Only the other party can accept the price suggestion."
        );
        // Update the price of the NFT
        artworks[tokenId].price = priceSuggestions[tokenId].newPrice;

        // Delete the price suggestion
        delete priceSuggestions[tokenId];
    }
}
