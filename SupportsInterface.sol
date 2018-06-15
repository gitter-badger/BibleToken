/**
 * @file SupportsInterface.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 * 
 * Utilizing 0xcert's ERC721 token implementation
 * https://0xcert.org/
 */

pragma solidity ^0.4.20;

import "./ERC165.sol";

/**
 * @title SupportsInterface
 * @dev Implementation of standard to detect smart contract interfaces.
 */
contract SupportsInterface is ERC165 {

    /**
    * @dev Mapping of supported interfaces.
    * @notice You must not set element 0xffffffff to true.
    */
    mapping(bytes4 => bool) internal supportedInterfaces;

    /**
    * @dev Contract constructor.
    */
    function SupportsInterface()
        public
    {
        supportedInterfaces[0x01ffc9a7] = true; // ERC165
    }

    /**
    * @dev Function to check which interfaces are suported by this contract.
    * @param _interfaceId Id of the interface.
    */
    function supportsInterface(
        bytes4 _interfaceId
    )
        external
        view
        returns (bool)
    {
        return supportedInterfaces[_interfaceId];
    }

}
