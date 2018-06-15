/**
 * @file Ownable.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 * 
 * Utilizing 0xcert's ERC721 token implementation
 * https://0xcert.org/
 */

pragma solidity ^0.4.20;

/**
 * @title Ownable
 * @dev The contract has an owner address, and provides basic authorization control whitch
 * simplifies the implementation of user permissions. This contract is based on the source code
 * at https://goo.gl/n2ZGVt.
 */
contract Ownable {
    
    /**
    * @dev The owner of the contact.
    */
    address public owner;

    /**
    * @dev An event which is triggered when the owner is changed.
    * @param previousOwner The address of the previous owner.
    * @param newOwner The address of the new owner.
    */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
    * @dev The constructor sets the original `owner` of the contract to the sender account.
    */
    function Ownable()
        public
    {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(
        address _newOwner
    )
        onlyOwner
        public
    {
        require(_newOwner != address(0));
        OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

}
