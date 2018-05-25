pragma solidity ^0.4.18;

import "./ERC721Standard.sol";

/// @title ERC721Enumerable, optional enumeration extension
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
contract ERC721Enumerable is ERC721Standard {
    function totalSupply() public view returns (uint256);
    function tokenByIndex(uint256 _index) public view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
}