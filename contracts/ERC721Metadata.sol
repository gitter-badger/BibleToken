/**
 * @file ERC721Metadata.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 * 
 * Utilizing 0xcert's ERC721 token implementation
 * https://0xcert.org/
 */

pragma solidity ^0.4.20;

/**
 * @title ERC721Metadata
 * @dev Optional metadata extension for ERC-721 non-fungible token standard.
 * See https://goo.gl/pc9yoS.
 */
interface ERC721Metadata {

    /**
    * @dev Returns a descriptive name for a collection of NFTs in this contract.
    */
    function name()
        external
        view
        returns (string _name);

    /**
    * @dev Returns a abbreviated name for a collection of NFTs in this contract.
    */
    function symbol()
        external
        view
        returns (string _symbol);

}
