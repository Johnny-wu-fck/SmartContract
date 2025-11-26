// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is ReentrancyGuard, Ownable {
    
    struct Listing {
        address seller;
        address nft;
        uint256 tokenId;
        address payToken;
        uint256 price;
        bool active;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    uint256 public feeRate = 250;
    uint256 public constant FEE_DENOMINATOR = 10000;
    mapping(address => uint256) public platformFees;

    event ItemListed(address indexed seller, address indexed nft, uint256 indexed tokenId, address payToken, uint256 price);
    event ItemSold(address indexed buyer, address indexed seller, address indexed nft, uint256 tokenId, address payToken, uint256 price);
    event ListingCancelled(address indexed seller, address indexed nft, uint256 indexed tokenId);
    event PriceUpdated(address indexed seller, address indexed nft, uint256 indexed tokenId, uint256 newPrice);
    event FeeRateUpdated(uint256 newFeeRate);


    constructor() Ownable() {
    }

    function listItem(address nft, uint256 tokenId, address payToken, uint256 price) external nonReentrant {
        require(price > 0, "Marketplace: price must be greater than 0");
        require(payToken != address(0), "Marketplace: invalid pay token");
        
        IERC721 nftContract = IERC721(nft);
        require(nftContract.ownerOf(tokenId) == msg.sender, "Marketplace: caller is not the owner");
        require(
            nftContract.isApprovedForAll(msg.sender, address(this)) || nftContract.getApproved(tokenId) == address(this),
            "Marketplace: marketplace not approved"
        );

        listings[nft][tokenId] = Listing({
            seller: msg.sender,
            nft: nft,
            tokenId: tokenId,
            payToken: payToken,
            price: price,
            active: true
        });

        emit ItemListed(msg.sender, nft, tokenId, payToken, price);
    }

    function buyItem(address nft, uint256 tokenId) external nonReentrant {
        Listing memory listing = listings[nft][tokenId];
        
        require(listing.active, "Marketplace: item not for sale");
        require(msg.sender != listing.seller, "Marketplace: cannot buy your own NFT");

        listings[nft][tokenId].active = false;

        uint256 fee = (listing.price * feeRate) / FEE_DENOMINATOR;
        uint256 sellerProceeds = listing.price - fee;

        IERC20(listing.payToken).transferFrom(msg.sender, listing.seller, sellerProceeds);

        if (fee > 0) {
            IERC20(listing.payToken).transferFrom(msg.sender, address(this), fee);
            platformFees[listing.payToken] += fee;
        }

        IERC721(nft).safeTransferFrom(listing.seller, msg.sender, tokenId);

        emit ItemSold(msg.sender, listing.seller, nft, tokenId, listing.payToken, listing.price);
    }

    function cancelListing(address nft, uint256 tokenId) external nonReentrant {
        Listing memory listing = listings[nft][tokenId];
        
        require(listing.active, "Marketplace: listing not active");
        require(msg.sender == listing.seller, "Marketplace: caller is not the seller");

        listings[nft][tokenId].active = false;

        emit ListingCancelled(msg.sender, nft, tokenId);
    }

    function updatePrice(address nft, uint256 tokenId, uint256 newPrice) external nonReentrant {
        require(newPrice > 0, "Marketplace: price must be greater than 0");
        
        Listing storage listing = listings[nft][tokenId];
        
        require(listing.active, "Marketplace: listing not active");
        require(msg.sender == listing.seller, "Marketplace: caller is not the seller");

        listing.price = newPrice;

        emit PriceUpdated(msg.sender, nft, tokenId, newPrice);
    }

    function getListing(address nft, uint256 tokenId) external view returns (Listing memory) {
        return listings[nft][tokenId];
    }

    function setFeeRate(uint256 newFeeRate) external onlyOwner {
        require(newFeeRate <= 1000, "Marketplace: fee rate too high");
        feeRate = newFeeRate;
        emit FeeRateUpdated(newFeeRate);
    }

    function withdrawFees(address token) external onlyOwner {
        uint256 amount = platformFees[token];
        require(amount > 0, "Marketplace: no fees to withdraw");

        platformFees[token] = 0;
        IERC20(token).transfer(msg.sender, amount);
    }

    function getListings(address nft, uint256[] calldata tokenIds) external view returns (Listing[] memory) {
        Listing[] memory result = new Listing[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            result[i] = listings[nft][tokenIds[i]];
        }
        return result;
    }
}
















// pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// contract Marketplace is ReentrancyGuard, Ownable {
    
//     struct Listing {
//         address seller;
//         address nft;
//         uint256 tokenId;
//         address payToken;
//         uint256 price;
//         bool active;
//     }

//     mapping(address => mapping(uint256 => Listing)) public listings;
//     uint256 public feeRate = 250;
//     uint256 public constant FEE_DENOMINATOR = 10000;
//     mapping(address => uint256) public platformFees;

//     event ItemListed(address indexed seller, address indexed nft, uint256 indexed tokenId, address payToken, uint256 price);
//     event ItemSold(address indexed buyer, address indexed seller, address indexed nft, uint256 tokenId, address payToken, uint256 price);
//     event ListingCancelled(address indexed seller, address indexed nft, uint256 indexed tokenId);
//     event PriceUpdated(address indexed seller, address indexed nft, uint256 indexed tokenId, uint256 newPrice);
//     event FeeRateUpdated(uint256 newFeeRate);

//     constructor() Ownable(msg.sender) {}

//     function listItem(address nft, uint256 tokenId, address payToken, uint256 price) external nonReentrant {
//         require(price > 0, "Marketplace: price must be greater than 0");
//         require(payToken != address(0), "Marketplace: invalid pay token");
        
//         IERC721 nftContract = IERC721(nft);
//         require(nftContract.ownerOf(tokenId) == msg.sender, "Marketplace: caller is not the owner");
//         require(
//             nftContract.isApprovedForAll(msg.sender, address(this)) || nftContract.getApproved(tokenId) == address(this),
//             "Marketplace: marketplace not approved"
//         );

//         listings[nft][tokenId] = Listing({
//             seller: msg.sender,
//             nft: nft,
//             tokenId: tokenId,
//             payToken: payToken,
//             price: price,
//             active: true
//         });

//         emit ItemListed(msg.sender, nft, tokenId, payToken, price);
//     }

//     function buyItem(address nft, uint256 tokenId) external nonReentrant {
//         Listing memory listing = listings[nft][tokenId];
        
//         require(listing.active, "Marketplace: item not for sale");
//         require(msg.sender != listing.seller, "Marketplace: cannot buy your own NFT");

//         listings[nft][tokenId].active = false;

//         uint256 fee = (listing.price * feeRate) / FEE_DENOMINATOR;
//         uint256 sellerProceeds = listing.price - fee;

//         IERC20(listing.payToken).transferFrom(msg.sender, listing.seller, sellerProceeds);

//         if (fee > 0) {
//             IERC20(listing.payToken).transferFrom(msg.sender, address(this), fee);
//             platformFees[listing.payToken] += fee;
//         }

//         IERC721(nft).safeTransferFrom(listing.seller, msg.sender, tokenId);

//         emit ItemSold(msg.sender, listing.seller, nft, tokenId, listing.payToken, listing.price);
//     }

//     function cancelListing(address nft, uint256 tokenId) external nonReentrant {
//         Listing memory listing = listings[nft][tokenId];
        
//         require(listing.active, "Marketplace: listing not active");
//         require(msg.sender == listing.seller, "Marketplace: caller is not the seller");

//         listings[nft][tokenId].active = false;

//         emit ListingCancelled(msg.sender, nft, tokenId);
//     }

//     function updatePrice(address nft, uint256 tokenId, uint256 newPrice) external nonReentrant {
//         require(newPrice > 0, "Marketplace: price must be greater than 0");
        
//         Listing storage listing = listings[nft][tokenId];
        
//         require(listing.active, "Marketplace: listing not active");
//         require(msg.sender == listing.seller, "Marketplace: caller is not the seller");

//         listing.price = newPrice;

//         emit PriceUpdated(msg.sender, nft, tokenId, newPrice);
//     }

//     function getListing(address nft, uint256 tokenId) external view returns (Listing memory) {
//         return listings[nft][tokenId];
//     }

//     function setFeeRate(uint256 newFeeRate) external onlyOwner {
//         require(newFeeRate <= 1000, "Marketplace: fee rate too high");
//         feeRate = newFeeRate;
//         emit FeeRateUpdated(newFeeRate);
//     }

//     function withdrawFees(address token) external onlyOwner {
//         uint256 amount = platformFees[token];
//         require(amount > 0, "Marketplace: no fees to withdraw");

//         platformFees[token] = 0;
//         IERC20(token).transfer(msg.sender, amount);
//     }

//     function getListings(address nft, uint256[] calldata tokenIds) external view returns (Listing[] memory) {
//         Listing[] memory result = new Listing[](tokenIds.length);
//         for (uint256 i = 0; i < tokenIds.length; i++) {
//             result[i] = listings[nft][tokenIds[i]];
//         }
//         return result;
//     }
// }
