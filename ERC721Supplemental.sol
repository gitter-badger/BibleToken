pragma solidity ^0.4.18;

import "./ERC721Standard.sol";

/// @title ERC721Supplemental, for supplemental functions used in this implementation
contract ERC721Supplemental is ERC721Standard {
    function exists(uint256 _tokenId) public view returns (bool);
}