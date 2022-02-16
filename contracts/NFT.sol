// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";

contract NFT is ERC721, PullPayment, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    
    /// Constants
    uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.08 ether;
    string private constant METADATA_EXT = ".json";
    
    /// @dev Base token URI used as a prefix by tokenURI().
    string public baseTokenURI;
    mapping(address => bool) public whitelisted;

    constructor() ERC721("NFTTutorial", "NFT") {
        baseTokenURI = "ipfs://bafybeigmomt3xk7lpts6iykvksq35xvqaabkg47sio5nu3io6u3s4i22ay/metadata/";
    }
    
    function mint(address recipient) public payable returns (uint256) {
        uint256 tokenId = currentTokenId.current();
        require(tokenId < TOTAL_SUPPLY, "Max supply reached");

        if (msg.sender != owner()) {
            if(whitelisted[msg.sender] != true) {
                require(msg.value >= MINT_PRICE, "Transaction value is less than the mint price");
            }
        }
        
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    // public
    function mintMany(address recipient, uint256 mintAmount) public payable {
        uint256 tokenId = currentTokenId.current();
        
        require(mintAmount > 0);
        require(tokenId + mintAmount < TOTAL_SUPPLY, "Exceeds maximum supply");

        if (msg.sender != owner()) {
            if(whitelisted[msg.sender] != true) {
                require(msg.value >= MINT_PRICE * mintAmount, "Transaction value is less than total mint price");
            }
        }

        for (uint256 i = 1; i <= mintAmount; i++) {
            currentTokenId.increment();
            _safeMint(recipient, currentTokenId.current());
        }
    }

    /// @dev Override token URI to append .json
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), METADATA_EXT)) : "";
    }

    /// @dev Returns an URI for a given token ID
    function _baseURI() internal view virtual override returns (string memory) {
       return baseTokenURI;
    }

    /// @dev Sets the base token URI prefix.
    function setBaseTokenURI(string memory _baseTokenURI) onlyOwner public {
      baseTokenURI = _baseTokenURI;
    }

    /// @dev Overridden in order to make it an onlyOwner function
    function withdrawPayments(address payable payee) public override onlyOwner virtual {
        super.withdrawPayments(payee);
    }
}