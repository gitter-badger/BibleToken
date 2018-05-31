pragma solidity ^0.4.20;

import "./BibleTokenBase.sol";
import "./BibleTokenOwnership.sol";
import "./ERC721Enumerable.sol";

/**
 * @dev Optional enumeration implementation for ERC-721 non-fungible token standard.
 */
contract BibleTokenEnumerable is BibleTokenBase, BibleTokenOwnership, ERC721Enumerable {

    /**
    * @dev Array of all NFT IDs.
    */
    Token[] internal tokens;

    /**
    * @dev Mapping from owner address to a list of owned NFT IDs.
    */
    //mapping(uint256 => uint256) internal idToIndex; // For the _mint and _burn methods in 0xcert's contract implementation

    /**
    * @dev Mapping from owner to list of owned NFT IDs.
    */
    mapping(address => uint256[]) internal ownerToIndices; // TODO possibly implement a method to return the array for people interested

    /**
    * @dev Mapping from NFT ID to its index in the owner tokens list.
    */
    //mapping(uint256 => uint256) internal idToOwnerIndex; // For the _mint and _burn methods in 0xcert's contract implementation

    /**
    * @dev Contract constructor.
    */
    function BibleTokenEnumerable()
        public
    {
        //supportedInterfaces[bytes4(
        //    (keccak256("totalSupply()")) ^
        //    (keccak256("tokenByIndex(uint256)")) ^
        //    (keccak256("tokenOfOwnerByIndex(address,uint256)")))] = true; // ERC721Enumerable; 0x780e9d63
        
        supportedInterfaces[bytes4(keccak256("totalSupply()"))] = true; // ERC721Enumerable (only method totalSupply(); 0x18160ddd
    }

    /**
    * @dev Returns the count of all existing NFTokens.
    */
    function totalSupply()
        external
        view
        returns (uint256)
    {
        return tokens.length;
    }

    /**
    * @dev Returns NFT ID by its index.
    * @param _index A counter less than `totalSupply()`.
    */
    //function tokenByIndex(
    //    uint256 _index
    //)
    //    external
    //    view
    //    returns (uint256)
    //{
    //    require(_index < tokens.length);
    //    return tokens[_index];
    //}

    /**
    * @dev returns the n-th NFT ID from a list of owner's tokens.
    * @param _owner Token owner's address.
    * @param _index Index number representing n-th token in owner's list of tokens.
    */
    //function tokenOfOwnerByIndex(
    //    address _owner,
    //    uint256 _index
    //)
    //    external
    //    view
    //    returns (uint256)
    //{
    //    require(_index < ownerToIds[_owner].length);
    //    return ownerToIds[_owner][_index];
    //}

}
