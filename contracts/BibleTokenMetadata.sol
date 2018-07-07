/**
 * @file BibleTokenMetadata.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 * 
 * Utilizing 0xcert's ERC721 token implementation
 * https://0xcert.org/
 */

pragma solidity ^0.4.20;

import "./BibleTokenOwnership.sol";
import "./ERC721Metadata.sol";

/**
 * @title BibleTokenMetadata
 * @dev Optional metadata implementation for ERC-721 non-fungible token standard.
 */
contract BibleTokenMetadata is
    BibleTokenOwnership,
    ERC721Metadata
{

    /**
    * @dev The name of the token.
    */
    string private tokenName = "BibleToken";

    /**
    * @dev The abbreviated symbol of the token.
    */
    string private tokenSymbol = "BT";

    /**
    * @dev Contract constructor.
    */
    function BibleTokenMetadata(
    )
        public
    {
        supportedInterfaces[bytes4(
            (keccak256("name()")) ^
            (keccak256("symbol()")))] = true; // ERC721Metadata; 0x93254542
    }

    /**
    * @dev Returns the name of the token.
    */
    function name()
        external
        view
        returns (string)
    {
        return tokenName;
    }

    /**
    * @dev Returns the abbreviated symbol of the token.
    */
    function symbol()
        external
        view
        returns (string)
    {
        return tokenSymbol;
    }

}
