// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Erros
error NftMarketplace__PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error NftMarketplace__NotOwner();
error NftMarketplace__NotListed();
error NftMarketplace__AlreadyListed();
error NftMarketplace__ItemListed();
error NftMarketplace__PriceMustBeAboveZero();
error NftMarketplace__NotApproved();
error NftMarketplace__NoProceeds();

contract NftMarketplace is ReentrancyGuard {
    struct Listing {
        uint256 price;
        address seller;
    }
    event ItemListed(address indexed from, address indexed nftAddress, uint256 indexed tokenId, uint256 price );
    event ItemCancelled(address indexed from, address indexed nftAddress, uint256 indexed tokenId);
    event ItemBought(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    mapping(address => mapping(uint256 => Listing)) private s_listing;
    mapping(address => uint) private s_proceeds;

    // 
    modifier isOwner(address nftAddress, uint256 tokenId, address spender) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (owner != spender){
            revert NftMarketplace__NotOwner();
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory newItem = s_listing[nftAddress][tokenId];
        if(newItem.price <= 0){
            revert NftMarketplace__NotListed();
        }
        _;
    }
    modifier notListed(address nftAddress, uint256 tokenId) {
        Listing memory newItem = s_listing[nftAddress][tokenId];
        if(0<newItem.price){
            revert NftMarketplace__AlreadyListed();
        }
        _;
    }


    ///////////////////
    // Main Function //
    ///////////////////
    /* 
    * @notice Method for listing NFT
    * @param nftAddress Address of NFT
    * @param tokenId Token ID for NFT
    * @param price Sale price of each Item
    */ 
    function ListItem(address nftAddress, uint256 tokenId, uint256 price) external isOwner(nftAddress, tokenId, msg.sender) isListed(nftAddress, tokenId) {
        
        if(price<0){
           revert NftMarketplace__PriceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if(nft.getApproved(tokenId) != address(this)){
            revert NftMarketplace__NotApproved();
        }
        s_listing[nftAddress][tokenId] = Listing(price,msg.sender );

        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }
    /*  
    * @notice Method for cancel Listing
    * @param nftAddress Address of NFT
    * @param tokenId Token ID of NFT
     */
    function cancelListing(address nftAddress, uint256 tokenId) external isOwner(nftAddress, tokenId, msg.sender) isListed(nftAddress, tokenId){
        delete s_listing[nftAddress][tokenId];
        emit ItemCancelled(msg.sender, nftAddress, tokenId);
    }

    /* 
    * @notice Method for buy NFT
    * @param nftAddress Address of NFT
    * @param tokenId Token ID of NFT
    */
    function buyItem(address nftAddress, uint256 tokenId) external payable isListed(nftAddress, tokenId) nonReentrant {
        Listing memory listedItem = s_listing[nftAddress][tokenId];
        if(msg.value<listedItem.price){
            revert NftMarketplace__PriceNotMet(nftAddress, tokenId, listedItem.price);

        }
        s_proceeds[listedItem.seller] += msg.value;

        delete (s_listing[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(listedItem.seller ,msg.sender, tokenId);
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
        
    }

    /* 
    * @notice Method for update NFT
    * @param nftAddress Address of NFT
    * @param tokenId Token ID of NFT
    * @param newPrice New price for Each Item
    */
    function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice) external isListed(nftAddress, tokenId) nonReentrant isOwner(nftAddress, tokenId, msg.sender) {
       
       if(newPrice <= 0){
        revert NftMarketplace__PriceMustBeAboveZero();
       }
       s_listing[nftAddress][tokenId].price = newPrice;
       emit ItemListed(msg.sender, nftAddress, tokenId, newPrice); 
    }

    /*
    * @notive Methods for withdrawing proceeds from sale
    */
    function withdrawProceeds() external {
        uint256 proceeds = s_proceeds[msg.sender];
        if(proceeds<=0){
            revert NftMarketplace__NoProceeds();
        }
        (bool success,) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer Failed!");
    }

    //////////////////////
    // Getter Function //
    /////////////////////
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory){
        return s_listing[nftAddress][tokenId];
    }

    function getProceed(address seller) external view returns (uint){
        return s_proceeds[seller];
    }
}

// Objective/ Goals
// MAIN function 
// 1. List Nft 
// 2. buy Nft
// 3. sell Nft
// 4. withdraw money

// GETTER function
// getListing
// getProceeds
