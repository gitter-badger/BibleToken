/**
 * @file BibleTokenEnumerable.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 * 
 * Utilizing 0xcert's ERC721 token implementation
 * https://0xcert.org/
 */

pragma solidity ^0.4.20;

import "./BibleTokenBase.sol";
import "./BibleTokenOwnership.sol";
import "./ERC721Enumerable.sol";

/**
 * @title BibleTokenEnumerable
 * @dev Optional enumeration implementation for ERC-721 non-fungible token standard.
 */
contract BibleTokenEnumerable is
    BibleTokenBase,
    BibleTokenOwnership,
    ERC721Enumerable
{

    /**
    * @dev Array of all BibleTokens.
    */
    Token[] internal tokens;

    /**
    * @dev Contract constructor.
    */
    function BibleTokenEnumerable()
        public
    {
        supportedInterfaces[bytes4(keccak256("totalSupply()"))] = true; // ERC721Enumerable (only method totalSupply(); 0x18160ddd
    }

    /**
    * @dev Returns the count of all existing BibleTokens.
    */
    function totalSupply()
        external
        view
        returns (uint256)
    {
        return tokens.length;
    }

}
