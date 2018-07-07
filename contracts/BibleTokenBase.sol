/**
 * @file BibleTokenBase.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 */

pragma solidity ^0.4.20;

/**
 * @title BibleTokenBase
 * @dev This contract is the base contract upon which the idea of BibleToken will
 * be built upon. It includes the Token data structure and the necessary state variables
 * that allow the contract to keep track of which verse is to be minted next.
 */
contract BibleTokenBase {

    /*** DATA TYPES ***/

    /**
    * @dev The primary data structure that signifies a verse in the Bible.
    * The structure is akin to if you were to open up your Bible to find a particular verse.
    * First you go to the name of the book.
    * Then you search through the book until you come to the chapter you're looking for.
    * Next you go the verse number.
    * And lastly you read the verse at that given number.
    */
    struct Token {
        string bookName;
        uint8  chapterNumber;
        uint8  verseNumber;
        string verseText;
    }

    /*** CONSTANTS ***/
    
    /**
    * @dev This constant goes hand-in-hand with its counterpart variable, `bookCompleted`.
    * They are needed so that the contract can keep track of if the entire Bible has been minted.
    * If it has, then it will be no longer possible to mint a verse, since the entire Bible
    * will have been written to the blockchain.
    */
    uint8 constant internal totalBooks = 66;

    /*** STORAGE ***/
    
    /**
    * @dev This variable is the URL of the BibleData.xml file that is stored on the IPFS.
    */
    string internal url;
    
    /**
    * @dev This variable keeps track of how many books have been completed.
    */
    uint8  public booksCompleted;
    
    /**
    * @dev These variables, including the above, `booksCompleted`, are essentially the
    * state of the contract. They will change accordingly when after a verse has been
    * successfully minted.
    */
    string public currentBookName;
    uint8  public currentNumberOfChapters;
    uint8  public currentChapterVersesNumber;
    uint8  public currentChapterNumber;
    uint8  public currentVerseNumber;
    
}
