/**
 * @file BibleTokenMinting.sol
 * @author John DeBord <i@johndebord.tk>
 * @date 2018
 */

pragma solidity ^0.4.20;

import "./BibleTokenEnumerable.sol";
import "./Oraclize.sol";

/**
 * @title BibleTokenMinting
 * @dev This contract is where all the action takes place. It contains all the necessary functions
 * and variables for the minting process to take place; heavily utilizing the Oraclize API.
 */
contract BibleTokenMinting is
    BibleTokenEnumerable,
    usingOraclize
{
    
    /**
    * @dev This enumeration is used specifically for the `__callback` function; when an Oraclize query
    * is sent out the function sending the store the query type to the mapping `queryToType`.
    * Thus when Oraclize calls the `__callback` function it will know exactly which functions to execute;
    * whether that be minting a token or updating certain state variables.
    */
    enum QueryType {GET_VERSE, GET_CHAPTER_VERSES, GET_BOOK_NAME, GET_NUMBER_OF_CHAPTERS}
    
    /**
    * @dev This mapping is used hand-in-hand with the enumeration `QueryType`, so that the query types
    * can be effectively stored, looked-up, and deleted upon completion of whatever functionaility was called.
    */
    mapping (bytes32 => QueryType) queryToType;
    
    /**
    * @dev This mapping is very important; without it, there would be no way for a BibleToken to get
    * minted to any address. Thus this mappng is used to keep track of the query Ids and their associated
    * addresses (`msg.sender`). The Id will get written to this mapping upon a successfull query. And will
    * then get deleted upon completion of the minting process.
    */
    mapping (bytes32 => address) queryToSender;
    
    /**
    * @dev These variables are for the gas limites of all the Oraclize queries in this contract.
    */
    uint256 mintVerseGasLimit = 2000000;
    uint256 updateBookNameGasLimit = 100000;
    uint256 updateNumberOfChaptersGasLimit = 100000;
    uint256 updateChapterVersesIGasLimit = 100000;
    uint256 updateChapterVersesIIGasLimit = 100000;
    
    /**
    * @dev This variable is used to sustain the contract's halting functionality in between tokens
    * getting minted. When an Oraclize query is sent out this counter is incremented.
    * When the `__callback` completes its duty the counter will get decremented.
    * After it gets decremented this variable gets checked if there are any other Oraclize queries that
    * have not yet completed. The counter will be == 0 once all `__callbacks` have been completed;
    * otherwise this variable will be non-zero.
    */
    uint8 public queryCount = 0;
    
    /**
    * @dev This variable controls how the contract halts other mint calls while it is already currently
    * minting a verse. It acts just like the `pause()` function, except that it is purely internal,
    * so that no one from the outside can halt the minting process whenever they want.
    * This variable works hand-in-hand with the halt modifier and halt function.
    */
    bool public halted = false;
    
    /**
    * @dev This variable acts as a flag so that the contract can know if the contract itself has the
    * permission to mint a token. Permission is granted (`contractIsMinting` is set to true) when
    * the contract determines that it has enough Ether to mint a verse; which happens right after the
    * contract is unhalted. This condition is checked and set in the `unhalt()` function and is set
    * back to false in the `ownerMint()` function.
    */
    bool public contractCanMint = false;
    
    /**
    * @dev Emits when a new BibleToken is minted.
    * @param _owner The owner of the BibleToken that has been minted.
    * @param _bookName The given book name in the Bible.
    * @param _chapterNumber The given chapter number in the Bible.
    * @param _verseNumber The given verse number in the Bible.
    * @param _verseText The text of that particular verse in the Bible.
    */
    event VerseMinted(
        address _owner,
        string _bookName,
        uint8 _chapterNumber,
        uint8 _verseNumber,
        string _verseText
    );
    
    /**
    * @dev Emits when a new Oraclize query is sent.
    * @param _description The description of the Oraclize query.
    */
    event OraclizeQuery(
        string _description
    );
    
    /**
    * @dev Emits when the contract has been halted to provide time for Oraclize to process the
    * data and for the contract to mint the BibleToken without any duplicate verses being written
    * to the Ethereum blockchain.
    */
    event Halt();
    
    /**
    * @dev Emits when the contract has been unhalted, so that the next verse can be minted.
    */
    event Unhalt();
    
    /**
    * @dev Modifier that controls if the Bible has been fully minted to the blockchain.
    * If it has, then minting a verse is no longer possible.
    */
    modifier booksIncomplete() {
        require(booksCompleted < totalBooks);
        _;
    }
    
    /**
    * @dev Modifier that checks to see is the contract is currently in the process of it being halted.
    * If it is halted, you will not be able to mint a verse.
    * Once the verse has been minted and all state variable have been updated, then will you be able to mint the next verse.
    */
    modifier whenNotHalted() {
        require(!halted);
        _;
    }

    /**
    * @dev Modifier that checks to see if the contract is currently in the process of being halted.
    * If it is not halted halted, then you will be able to mint the next verse.
    */
    modifier whenHalted() {
        require(halted);
        _;
    }
    
    /**
    * @dev This function halts the contract until the verse has been minted/written to the blockchain.
    * It is an internal function, so it can only be called from within the contract and not outside
    * from any individual.
    */
    function halt()
        whenNotHalted
        internal
    {
        halted = true;
        Halt();
    }

    /**
    * @dev This function unhalts the contract to allow the next verse to be minted/written to the blockchain.
    * @notice This function also checks to see if the contract's balance is >= 3 Ether, if it is then the contract
    * performs the `ownerMint()` function.
    */
    function unhalt()
        whenHalted
        internal
    {
        halted = false;
        Unhalt();
        
        if(this.balance >= 0.06 ether) {
            contractCanMint = true;
            ownerMint();
        }
    }
    
    /**
    * @dev Because funds will be accumulated whilst the Bible is being written to the blockchain
    * (around 400 Ether total), all Ether accumulated by this contract will be reinvested into
    * minting more verses to the blockchain. After the contract has been unhalted a check will be
    * performed to see what the current balance of the contract is. If the balance is >= 0.03 Ether,
    * the contract will execute another `mint()` function call. Thus more BibleTokens will get minted.
    */
    function ownerMint()
        internal
    {
        mint();
        contractCanMint = false;
    }
    
    /**
    * @dev This function is needed just in case any unforeseen Oraclize complications are run into.
    * Only the owner of the contract can access this function. The usage is after the contract state
    * variables have been audited by the owner, the owner will then unhalt the contract and also reset.
    * the current query count. This function should never be used, but it is still a must to have.
    */
    function ownerUnhalt()
        onlyOwner
        whenHalted
        external
    {
        halted = false;
        queryCount = 0;
        Unhalt();
    }
    
    /**
    * @dev This function controls when the contract is to be unhalted. `queryCount` initially starts
    * off at 0. But is incremented each time there is an Oraclize query.
    * Everytime Oraclize completes a `__callback` `queryCount` gets decremented by 1.
    * Once `queryCount` is 0 it is then safe to unhalt the contract.
    */
    function callbackCheck()
        internal
    {
        if(queryCount == 0) {
            unhalt();
        } else {
            return;
        }
    }
    
    /**
    * @dev This is where all the minting action takes place. Since a BibleToken cannot be minted
    * unless it has the appropriate data, and that is only possible after the Oraclize query.
    * Thus when someone calls the mint function, they will have to wait until Oraclize processes the query/queries
    * before they can access their BibleToken; which should take at most take 1 minute according to https://ethgasstation.info/.
    * @notice Depending on the `QueryType` a different branch of execution will follow; for example if the `QueryType`
    * is `GET_VERSE`, the `__callback` will perform the operations for minting the verse returned by `_result`.
    * @param _myid The ID of the query.
    * @param _result The result of the Oraclize query.
    */
    function __callback(
        bytes32 _myid,
        string _result
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());
        
        if(queryToType[_myid] == QueryType.GET_VERSE) {
            _mintBibleToken(_myid, _result);
            --queryCount;
            callbackCheck();
        } else if(queryToType[_myid] == QueryType.GET_CHAPTER_VERSES) {
            _updateChapterVerses(_myid, _result);
            --queryCount;
            callbackCheck();
        } else if(queryToType[_myid] == QueryType.GET_BOOK_NAME) {
            _updateBookName(_myid, _result);
            --queryCount;
            callbackCheck();
        } else if(queryToType[_myid] == QueryType.GET_NUMBER_OF_CHAPTERS) {
            _updateNumberOfChapters(_myid, _result);
            --queryCount;
            callbackCheck();
        } else {
            revert(); // ?
        }
    }
    
    /**
    * @dev This is the function to call when an address wishes to mint the next Bible verse.
    * It will not compute if the whole Bible has been minted to the blockchain, because then there will be
    * no other verses left to mint. Also, the address must send the appropriate payment to this contract,
    * because using the Oraclize service is not free. The amount sent must be the maximum needed to mint
    * any given verse in the Bible; the longest being Esther 8:9, at a total character count of 528.
    */
    function mint()
        whenNotHalted
        booksIncomplete
        payable
        public
    {
        require(msg.value == 0.06 ether || contractCanMint == true);
        
        halt();
        
        myOraclizeMintVerse();
    }
    
    /**
    * @dev This function does the nitty-gritty operations of constructing the BibleToken
    * and then pushing it to the array `tokens` that holds all of the BibleTokens.
    * After which the `queryToSender` and `queryToType` variables get deleted.
    * @param _myid The ID of the query.
    * @param _verseText The Bible verse that is retrieved.
    */
    function _mintBibleToken(
        bytes32 _myid,
        string _verseText
    )
        internal
    {
        Token memory token = Token({
            bookName: currentBookName,
            chapterNumber: currentChapterNumber,
            verseNumber: currentVerseNumber,
            verseText: _verseText
        });
        
        assert(bytes(token.verseText).length != 0);
        
        uint256 tokenIndex = tokens.push(token) - 1;
        _mint(queryToSender[_myid], tokenIndex);
        delete queryToType[_myid];
        delete queryToSender[_myid];
        
        update();
    }
    
    /**
    * @dev This function does even more of the nitty-gritty work of the minting process;
    * updating the data structures relating to ownership of the particular BibleToken.
    * @param _to The address to the owner of the BibleToken.
    * @param _tokenIndex The index of the given BibleToken in the `tokens` array.
    */
    function _mint(
        address _to,
        uint256 _tokenIndex
    )
        internal
    {
        assert(_to != address(0));
        assert(indexToOwner[_tokenIndex] == address(0));

        _addNFToken(_to, _tokenIndex);

        VerseMinted(
            _to,
            tokens[_tokenIndex].bookName,
            tokens[_tokenIndex].chapterNumber,
            tokens[_tokenIndex].verseNumber,
            tokens[_tokenIndex].verseText
        );
        
        Transfer(address(0), _to, _tokenIndex);
    }
    
    /**
    * @dev The purpose of this function is to keep a logically consistent flow of the inheritance structure of this contract.
    * @param _to The address to the owner of the BibleToken.
    * @param _tokenIndex The index of the given BibleToken in the `tokens` array.
    */
    function _addNFToken(
        address _to,
        uint256 _tokenIndex
    )
        internal
    {
        super.addNFToken(_to, _tokenIndex);
    }
    
    /**
    * @dev This function starts the update process that gets called at the end of minting a BibleToken.
    * This is very important to do so that the contract can always keep the appropriate state variables for
    * storing newly minted BibleTokens and for constructing Oraclize queries.
    */
    function update()
        internal
    {
        updateVerse();
    }
    
    /**
    * @dev This function updates the `currentVerseNumber` and then checks to see if it has surpassed
    * the number of verses that are in the given chapter. If it exceeds that specific amount,
    * it passes execution on to the `updateChapter()` function.
    */
    function updateVerse()
        internal
    {
        ++currentVerseNumber;
        if(currentVerseNumber > currentChapterVersesNumber) {
            updateChapter();
        }
        else {
            return;
        }
    }
    
    /**
    * @dev This function updates the `currentChapterNumber` and resets the `currentVerseNumber` to 1.
    * If the `currentChapterNumber` exceeds then execeution is passed on to the `updateBook()` function.
    */
    function updateChapter()
        internal
    {
        currentVerseNumber = 1;
        ++currentChapterNumber;
        if(currentChapterNumber > currentNumberOfChapters) {
            updateBook();
        } else {
            myOraclizeUpdateChapterVersesI();
        }
    }
    
    /**
    * @dev This function is called once a whole book has been minted to the blockchain.
    * Thus the contract must update the state variables to the next book in the Bible.
    * If every book has been completed, then all state variables are deleted and it will be no
    * longer possible to mint another verse to the blockchain through this contract.
    */
    function updateBook()
        internal
    {
        currentChapterNumber = 1;
        if((booksCompleted + 1) < totalBooks) {
            myOraclizeUpdateBookName();
            myOraclizeUpdateNumberOfChapters();
            myOraclizeUpdateChapterVersesII();
            ++booksCompleted;
        } else {
            ++booksCompleted;
            delete currentBookName;
            delete currentNumberOfChapters;
            delete currentChapterVersesNumber;
            delete currentChapterNumber;
            delete currentVerseNumber;
            return;
        }
    }
    
    /**
    * @dev This function updates the name of the book in the Bible that is retrieved.
    * This function is necessary so that the contract stores the right name in a minted BibleToken.
    * After which the `queryToType` variable get deleted.
    * @param _myid The ID of the query.
    * @param _bookName The name of the book of the Bible that is retrieved.
    */
    function _updateBookName(
        bytes32 _myid,
        string _bookName
    )
        internal
    {
        currentBookName = _bookName;
        delete queryToType[_myid];
        return;
    }
    
    /**
    * @dev This function updates the number of chapters in the given book in the Bible that is retrieved.
    * This function is necessary so that contract knows when to update the state variables when
    * every chapter in this book as been minted to the blockchain.
    * After which the `queryToType` variable get deleted.
    * @param _myid The ID of the query.
    * @param _numberOfChapters The number of chapters in the given book that is retrieved.
    */
    function _updateNumberOfChapters(
        bytes32 _myid,
        string _numberOfChapters
    )
        internal
    {
        currentNumberOfChapters = uint8(parseInt(_numberOfChapters));
        delete queryToType[_myid];
        return;
    }
    
    /**
    * @dev This function updates the number of verses in a given chapter. This is necessary for the contract
    * to know when it needs to get the data for the next chapter and for the contract to be able to store the
    * appropriate verse number in a minted BibleToken.
    * After which the `queryToType` variable get deleted.
    * @param _myid The ID of the query.
    * @param _chapterVerses The number of verses in the chapter that is retrieved.
    */
    function _updateChapterVerses(
        bytes32 _myid,
        string _chapterVerses
    )
        internal
    {
        currentChapterVersesNumber = uint8(parseInt(_chapterVerses));
        delete queryToType[_myid];
        return;
    }
    
    /**
    * @dev This function constructs the query string necessary for retrieving the text of a given Bible verse.
    * Once the string has been constructed using the `strConcat()` function provided by Oraclize, the
    * Oraclize query is sent out; afterwhich the `queryToType` and `queryToSender` variables are stored to
    * keep track of the query.
    */
    function myOraclizeMintVerse()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory query = url;
        
        query = strConcat(
            query,
            uint2str(booksCompleted + 1),
            "']/Chapter[@id='",
            uint2str(currentChapterNumber),
            "']/Verse[@id='"
        );
        query = strConcat(
            query,
            uint2str(currentVerseNumber),
            "']/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", query, mintVerseGasLimit);
        ++queryCount;
        queryToType[id] = QueryType.GET_VERSE;
        queryToSender[id] = msg.sender;
        
        OraclizeQuery("Query sent; awaiting response...");
    }
    
    /**
    * @dev This function constructs the query string necessary for retrieving a given book name in the Bible.
    * Once the string has been constructed using the `strConcat()` function provided by Oraclize, the
    * Oraclize query is sent out; afterwhich the `queryToType` variable is stored to keep track of the query.
    */
    function myOraclizeUpdateBookName()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory query = url;
        
        query = strConcat(
            query,
            uint2str(booksCompleted + 2),
            "']/bookName/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", query, updateBookNameGasLimit);
        ++queryCount;
        queryToType[id] = QueryType.GET_BOOK_NAME;
        
        OraclizeQuery("Query sent; awaiting response...");
    }
    
    /**
    * @dev This function constructs the query string necessary for retrieving the number of chapters in a given book in the Bible.
    * Once the string has been constructed using the `strConcat()` function provided by Oraclize, the
    * Oraclize query is sent out; afterwhich the `queryToType` variable is stored to keep track of the query.
    */
    function myOraclizeUpdateNumberOfChapters()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory query = url;
        
        query = strConcat(
            query,
            uint2str(booksCompleted + 2),
            "']/numberOfChapters/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", query, updateNumberOfChaptersGasLimit);
        ++queryCount;
        queryToType[id] = QueryType.GET_NUMBER_OF_CHAPTERS;
        
        OraclizeQuery("Query sent; awaiting response...");
    }
    
    /**
    * @dev This function constructs the query string necessary for retrieving the number of verses in a given Bible chapter.
    * Once the string has been constructed using the `strConcat()` function provided by Oraclize, the
    * Oraclize query is sent out; afterwhich the `queryToType` variable is stored to keep track of the query.
    * @notice There are two versions of this function; the first one constructs the query for a book that has not
    * been completed while the second one constructs the query for a book that has been completed.
    * This is needed because there would be complications the query after a book has been finished, because the `booksCompleted`
    * variable would not have been updated yet.
    */
    function myOraclizeUpdateChapterVersesI()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory query = url;
        
        query = strConcat(
            query,
            uint2str(booksCompleted + 1),
            "']/Chapter[@id='",
            uint2str(currentChapterNumber),
            "']/numberOfVerses/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", query, updateChapterVersesIGasLimit);
        ++queryCount;
        queryToType[id] = QueryType.GET_CHAPTER_VERSES;
        
        OraclizeQuery("Query sent; awaiting response...");
    }
    
    /**
    * @dev This function constructs the query string necessary for retrieving the number of verses in a given Bible chapter.
    * Once the string has been constructed using the `strConcat()` function provided by Oraclize, the
    * Oraclize query is sent out; afterwhich the `queryToType` variable is stored to keep track of the query.
    * @notice There are two versions of this function; the first one constructs the query for a book that has not
    * been completed while the second one constructs the query for a book that has been completed.
    * This is needed because there would be complications the query after a book has been finished, because the `booksCompleted`
    * variable would not have been updated yet.
    */
    function myOraclizeUpdateChapterVersesII()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory query = url;
        
        query = strConcat(
            query,
            uint2str(booksCompleted + 2),
            "']/Chapter[@id='",
            uint2str(currentChapterNumber),
            "']/numberOfVerses/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", query, updateChapterVersesIIGasLimit);
        ++queryCount;
        queryToType[id] = QueryType.GET_CHAPTER_VERSES;
        
        OraclizeQuery("Query sent; awaiting response...");
    }
    
}
