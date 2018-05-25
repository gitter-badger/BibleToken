pragma solidity ^0.4.18;

import "./ERC721Standard.sol";

/// @title ERC721Metadata, optional metadata extension
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
contract ERC721Metadata is ERC721Standard {
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    //function tokenURI(uint256 _tokenId) public view returns (string);
}