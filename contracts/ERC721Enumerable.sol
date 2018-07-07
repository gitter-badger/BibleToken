/**
 * @file ERC721Enumerable.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 * 
 * Utilizing 0xcert's ERC721 token implementation
 * https://0xcert.org/
 */

pragma solidity ^0.4.20;

/**
 * @title ERC721Enumerable
 * @dev Optional enumeration extension for ERC-721 non-fungible token standard.
 * See https://goo.gl/pc9yoS.
 */
interface ERC721Enumerable {

    /**
    * @dev Returns a count of valid NFTs tracked by this contract, where each one of them has an
    * assigned and queryable owner not equal to the zero address.
    */
    function totalSupply()
        external
        view
        returns (uint256);
        
}
