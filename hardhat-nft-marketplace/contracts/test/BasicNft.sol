// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    uint256 private s_tokenCounter;
    string private constant TOKEN_URI = "THIS_IS_TOKEN_URI";
    
    event DogMinted(uint256 indexed tokenId);

    constructor() ERC721("Doggie", "DOG") {
        s_tokenCounter = 0;
    }

    function mint() public {
        _safeMint(msg.sender, s_tokenCounter);
        emit DogMinted(s_tokenCounter);
        s_tokenCounter = s_tokenCounter +1;
    }

    // Getter function
    function tokenURI(uint256 /*tokenId*/) public pure override returns(string memory) {
        // require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return TOKEN_URI;
    }

    function getTokenCounter() view public returns(uint256){
        return s_tokenCounter;
    }
}