// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    
    // @dev Base token URI used as a prefix by tokenURI().
    string public baseTokenURI;

    constructor() ERC721("NFTTutorial", "NFT") {
        baseTokenURI = "ipfs://bafybeigmomt3xk7lpts6iykvksq35xvqaabkg47sio5nu3io6u3s4i22ay/metadata/";
    }
    
    function mintTo(address recipient)
        public
        returns (uint256)
    {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    // @dev Override token URI to append .json
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    // @dev Returns an URI for a given token ID
    function _baseURI() internal view virtual override returns (string memory) {
       return baseTokenURI;
    }

    // @dev Sets the base token URI prefix.
    function setBaseTokenURI(string memory _baseTokenURI) public {
      baseTokenURI = _baseTokenURI;
    }
}