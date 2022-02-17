// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";

contract OwnableDelegateProxy {}

/**
 * Used to delegate ownership of a contract to another address, to save on unneeded transactions to approve contract use for users
 */
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract NFT is ERC721, PullPayment, Ownable {
    /// Constants
    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.08 ether;
    string private constant METADATA_EXT = ".json";
    uint256 private constant MINT_AMOUNT = 10;
    
    /// @dev Base token URI used as a prefix by tokenURI().
    string public baseTokenURI;
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    mapping(address => bool) public whitelisted;
    address proxyRegistryAddress;
    

    constructor(string memory _name, string memory _symbol, string memory _baseTokenURI, address _proxyRegistryAddress) ERC721 (_name, _symbol) {
        baseTokenURI = _baseTokenURI;
        proxyRegistryAddress = _proxyRegistryAddress;
        // mint(msg.sender, MINT_AMOUNT);
    }

    /**
        @dev Returns the total tokens minted so far.
     */
    function totalSupply() public view returns (uint256) {
        return currentTokenId.current();
    }

    function maxSupply() public pure returns (uint256) {
        return MAX_SUPPLY;
    }

    
    /// public
    function mint(address recipient, uint256 mintAmount) public payable {
        uint256 tokenId = currentTokenId.current();
        
        require(mintAmount > 0);
        require(tokenId + mintAmount < MAX_SUPPLY, "Exceeds maximum supply");

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

    /// @dev Overridden in order to make it an onlyOwner function
    function withdrawPayments(address payable payee) public override onlyOwner virtual {
        super.withdrawPayments(payee);
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }

    
}