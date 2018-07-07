/**
 * @file Pausable.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 * 
 * Utilizing 0xcert's ERC721 token implementation
 * https://0xcert.org/
 */

pragma solidity ^0.4.20;

import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is
    Ownable
{
    
    /**
    * @dev Emits when the contract paused.
    */
    event Pause();
    
    /**
    * @dev Emits when the contract is unpaused.
    */
    event Unpause();

    /**
    * @dev The variable indicating if the contact is currently paused.
    */
    bool public paused = false;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause()
        onlyOwner
        whenNotPaused
        public
    {
        paused = true;
        Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause()
        onlyOwner
        whenPaused
        public
    {
        paused = false;
        Unpause();
    }
    
}
