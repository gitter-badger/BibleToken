/**
 * @file BibleTokenCore.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 */

pragma solidity ^0.4.20;

import "./BibleTokenMinting.sol";

/**
 * @title BibleTokenCore
 * @dev This contract gets the wheels turning; initializing the "Genesis" state
 * variables so that we can start writing/minted the Bible to the blockchain!
 * This contract also contains the additional function to look up and read any
 * given verse that has been written blockchain.
 */
contract BibleTokenCore is
    BibleTokenMinting
{
    
    /**
     * @dev The constructor of this contract; initialzes all state variables in
     * accordane to the book of "Genesis".
     */
    function BibleTokenCore()
        public
    {
        booksCompleted = 0;
        
        currentBookName = "Esther";
        currentNumberOfChapters = 1;
        currentChapterVersesNumber = 1;
        currentChapterNumber = 1;
        currentVerseNumber = 1;
    }
    
    /**
     * @dev This is the function that will allow anyone in the world that has access
     * to the Ethereum blockchain to be able to look up any verse in the Bible that has been minted
     * through this contract for no cost! That is the awesome part about writing the Bible
     * to the blockchain; that once it has been written, it will remain immutable and
     * be accessible to anyone who has access to the Ethereum blockchain.
     * @param _book The given book of the Bible.
     * @param _chapter The given chapter of the Bible.
     * @param _verse The given verse of the Bible.
     */
    function retrieveVerse(
        string _book,
        uint8 _chapter,
        uint8 _verse
    )
        view
        public
        returns (string)
    {
        // The maximum number of chapters that can be a book; Psalms has the most, at 150
        require((_chapter > 0) && (_chapter <= 150));
        // The maximum number of verses that can be in a chapter; Psalms 119 has the most at 176
        require((_verse > 0) && (_verse <= 176));
        
        for(uint256 i = 0; i < tokens.length; ++i) {
            // Using keccak256 because strings of type storage ref and string memory cannot compare
            if(keccak256(tokens[i].bookName) == keccak256(_book) &&
               tokens[i].chapterNumber == _chapter &&
               tokens[i].verseNumber == _verse)
               return tokens[i].verseText;
        }

        return "Verse not minted yet, or invalid Book Name.";
    }
    
    /**
     * @dev This function is used for debugging purposes when calculating the differing
     * Oraclize queries.
     */
    function addFunds()
        external
        payable
        returns (string)
    {
        return "Successfully added funds.";
    }
    
    /**
     * @dev This function is used for debugging purposes when calculating the differing
     * Oraclize queries.
     */
    function checkBalance()
        external
        view
        onlyOwner
        returns (uint256)
    {
        uint256 balance = this.balance;
        return balance;
    }
    
    /**
     * @dev Withdraws the current balance of the contract; this can only be done by the
     * owner of the contract.
     */
    function withdrawBalance()
        external
        onlyOwner
    {
        uint256 balance = this.balance;
        require(balance > 0);
        owner.send(balance);
    }
    
}
