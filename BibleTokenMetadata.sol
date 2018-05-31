pragma solidity ^0.4.20;

import "./BibleTokenOwnership.sol";
import "./ERC721Metadata.sol";

/**
 * @dev Optional metadata implementation for ERC-721 non-fungible token standard.
 */
contract BibleTokenMetadata is BibleTokenOwnership, ERC721Metadata {

    /**
    * @dev A descriptive name for a collection of NFTs.
    */
    string private tokenName = "BibleToken";

    /**
    * @dev An abbreviated name for NFTokens.
    */
    string private tokenSymbol = "BT";

    /**
    * @dev Mapping from NFT ID to metadata uri.
    */
    mapping (uint256 => string) internal indexToUri;

    /**
    * @dev Contract constructor.
    */
    function BibleTokenMetadata(
    )
        public
    {
        supportedInterfaces[bytes4(
            (keccak256("name()")) ^
            (keccak256("symbol()")) ^
            (keccak256("tokenURI(uint256)")))] = true; // ERC721Metadata; 0x5b5e139f
    }

    // TODO check this out if I want to implement it or not
    /**
    * @dev Set a distinct URI (RFC 3986) for a given NFT ID.
    * @notice this is a internal function which should be called from user-implemented external
    * function. Its purpose is to show and properly initialize data structures when using this
    * implementation.
    * @param _tokenIndex Id for which we want uri.
    * @param _uri String representing RFC 3986 URI.
    */
    function _setTokenUri(
        uint256 _tokenIndex,
        string _uri
    )
        validNFToken(_tokenIndex)
        internal
    {
        indexToUri[_tokenIndex] = _uri;
    }

    /**
    * @dev Returns a descriptive name for a collection of NFTokens.
    */
    function name()
        external
        view
        returns (string)
    {
        return tokenName;
    }

    /**
    * @dev Returns an abbreviated name for NFTokens.
    */
    function symbol()
        external
        view
        returns (string)
    {
        return tokenSymbol;
    }

    /**
    * @dev A distinct URI (RFC 3986) for a given NFT.
    * @param _tokenIndex Id for which we want uri.
    */
    function tokenURI(
        uint256 _tokenIndex
    )
        validNFToken(_tokenIndex)
        external
        view
        returns (string)
    {
        return indexToUri[_tokenIndex];
    }
}
