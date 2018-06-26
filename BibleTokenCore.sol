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
        url = "xml(QmWHM6Q1jLn5TszMQVYvLaSj3bug2qSkWGey3ExDGyoYQy).xpath(/Bible/Book[@id='";
        
        booksCompleted = 0;
        
        currentBookName = "Genesis";
        currentNumberOfChapters = 50;
        currentChapterVersesNumber = 31;
        currentChapterNumber = 1;
        currentVerseNumber = 1;
    }
    
    /**
     * @dev This function is for setting the gas price for Oraclize queries.
     * Needed for if the gas price of using the Oraclize service fluctuates.
     * Note that only the owner can call this function and the argument passed
     * must be in Wei.
     * @param _gasPrice The amount if Wei to set the Oraclize gas price.
     */
    function setOraclizeGasPrice(
        uint256 _gasPrice
    )
        onlyOwner
        whenPaused
        external
    {
        oraclize_setCustomGasPrice(_gasPrice);
    }
    
    /**
     * @dev This function is for setting the gas limits of the different Oraclize
     * queries, just in case the queries need tweaking in the future.
     * Note that only the owner can call this function and the argument passed
     * must be in Wei.
     * @param _mintVerseGasLimit For the mint verse query.
     * @param _updateBookNameGasLimit For the book name query.
     * @param _updateNumberOfChaptersGasLimit For the number of chapters query.
     * @param _updateChapterVersesIGasLimit For the chapter verses I query.
     * @param _updateChapterVersesIIGasLimit For the chapter verses II query.
     */
    function setOraclizeGasLimits(
        uint256 _mintVerseGasLimit,
        uint256 _updateBookNameGasLimit,
        uint256 _updateNumberOfChaptersGasLimit,
        uint256 _updateChapterVersesIGasLimit,
        uint256 _updateChapterVersesIIGasLimit
    )
        onlyOwner
        whenPaused
        external
    {
        mintVerseGasLimit = _mintVerseGasLimit;
        updateBookNameGasLimit = _updateBookNameGasLimit;
        updateNumberOfChaptersGasLimit = _updateNumberOfChaptersGasLimit;
        updateChapterVersesIGasLimit = _updateChapterVersesIGasLimit;
        updateChapterVersesIIGasLimit = _updateChapterVersesIIGasLimit;
    }
    
    /**
     * @dev This function sets the IPFS URL that is used by this contract.
     * Only the owner of the contract can change it. It is needed just in case
     * something happens where the BibleData on the IPFS is compromised. Note
     * that the new url must be specified in the format shown in the constructor.
     * This function should never be used, but it is still a must to have it.
     * @param _url The url state variable that may need to be audited.
     */
    function setURL(
        string _url
    )
        onlyOwner
        whenPaused
        external
    {
        url = _url;
    }
    
    /**
     * @dev This function sets all state variables to a certain value. This function is also needed just in case
     * there is a problem with the Oraclize API and somehow the state variables need to be reset in a way. Again,
     * this function should never be used, but is still a must to have.
     * @param _booksCompleted The booksCompleted state variable that may need to be audited.
     * @param _currentBookName The currentBookName state variable that may need to be audited.
     * @param _currentNumberOfChapters The currentNumberOfChapters state variable that may need to be audited.
     * @param _currentChapterVersesNumber The currentChapterVersesNumber state variable that may need to be audited.
     * @param _currentChapterNumber The currentChapterNumber state variable that may need to be audited.
     * @param _currentVerseNumber The currentVerseNumber state variable that may need to be audited.
     */
    function setStateVariables(
        uint8 _booksCompleted,
        string _currentBookName,
        uint8 _currentNumberOfChapters,
        uint8 _currentChapterVersesNumber,
        uint8 _currentChapterNumber,
        uint8 _currentVerseNumber
    )
        onlyOwner
        whenPaused
        external
    {
        booksCompleted = _booksCompleted;
        currentBookName = _currentBookName;
        currentNumberOfChapters = _currentNumberOfChapters;
        currentChapterVersesNumber = _currentChapterVersesNumber;
        currentChapterNumber = _currentChapterNumber;
        currentVerseNumber = _currentVerseNumber;
    }
    
    /**
     * @dev This function makes a correction to a verse just in case any data in a
     * verse gets corrupted somehow. This should NEVER happen. But alas, again, this
     * function should never be used, but is still a must to have.
     * @param _tokenIndex The index of the token that is to be audited.
     * @param _bookName The name of the book that may need to be audited.
     * @param _chapterNumber The chapter number that may need to be audited.
     * @param _verseNumber The verse number that may need to be audited.
     * @param _verseText The text of the verse that may need to be audited.
     */
    function auditVerse(
        uint256 _tokenIndex,
        string _bookName,
        uint8 _chapterNumber,
        uint8 _verseNumber,
        string _verseText
    )
        onlyOwner
        whenPaused
        external
    {
        tokens[_tokenIndex].bookName = _bookName;
        tokens[_tokenIndex].chapterNumber = _chapterNumber;
        tokens[_tokenIndex].verseNumber = _verseNumber;
        tokens[_tokenIndex].verseText = _verseText;
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
        onlyOwner
        external
        view
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
        onlyOwner
        external
    {
        uint256 balance = this.balance;
        require(balance > 0);
        owner.send(balance);
    }
    
}
