pragma solidity ^0.4.20;

import "./BibleTokenEnumerable.sol";
import "./Oraclize.sol";

contract BibleTokenMinting is BibleTokenEnumerable, usingOraclize {
    
    /**
    * @dev The VerseMinted event is fired when a new BibleToken is minted.
    */
    event VerseMinted(
        address _owner,
        string _bookName,
        uint8 _chapterNumber,
        uint8 _verseNumber,
        string _verseText
    );
    
    /**
    * @dev The OraclizeQuery event is fired when a new Oraclize query is sent.
    */
    event OraclizeQuery(
        string description
    );
    
    /**
    * @dev Modifier that controls if the Bible has been fully minted to the blockchain.
    * If it has, then minting a verse is no longer possible.
    */
    modifier booksIncomplete() {
        require(booksCompleted < booksOfTheBible.length);
        _;
    }
    
    /**
    * @dev This mapping is very important; without it, there would be no way for a BibleToken to get minted to any address.
    * Thus this mappng is used to keep track of the query Ids and their associated addresses (msg.sender).
    * The Id will get written to this mapping on a successfull query. And will then get deleted upon completion of the minting process.
    */
    mapping (bytes32 => address) queryIds;
    
    /**
    * @dev This is where all the minting action takes place. Since a BibleToken cannot be minted
    * unless it has the appropriate data, and that is only possible after the Oraclize query.
    * Thus when someone calls the mint function, they will have to wait until Oraclize processes the query
    * before they can access their BibleToken; which should take at most a couple minutes.
    */
    function __callback(
        bytes32 myid,
        string result
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());
        
        if(queryIds[myid] != address(0))
        {
            Token memory token = Token({
                bookName: currentBookName,
                chapterNumber: currentChapterNumber,
                verseNumber: currentVerseNumber,
                verseText: result
            });
            
            //assert(token.verseText.length != 0);
            
            uint256 tokenIndex = tokens.push(token) - 1;
            _mint(queryIds[myid], tokenIndex);
            delete queryIds[myid];
            ++currentVerseNumber;
        }
        
        if(!(currentVerseNumber < currentChapterVerses[currentChapterNumber])) {
            currentVerseNumber = 1;
            ++currentChapterNumber;
        }
        
        if(!(currentChapterNumber < currentChapterVerses.length)) {
            currentChapterNumber = 1;
            myOraclizeUpdateBook();
        }
        
        currentURL = constructVerseTextURL();
    }
    
    /**
    * @dev This is the function to call when an address wishes to mint the next Bible verse.
    * It will not compute if the whole Bible has been minted to the blockchain, because then there will be
    * no other verses left to mint. Also, the address must send the appropriate payment to this contract,
    * because using the Oraclize service is not free. The amount sent must be the maximum needed to mint
    * any given verse in the Bible; the longest being Esther 8:9, at a total character count of 528.
    */
    function mint()
        payable
        external
        booksIncomplete
    {
        require(msg.value == 1 ether);
        
        //if(!(currentVerseNumber < currentChapterVerses[currentChapterNumber])) {
        //    currentVerseNumber = 1;
        //    ++currentChapterNumber;
        //}
        
        //if(!(currentChapterNumber < currentChapterVerses.length)) {
        //    currentChapterNumber = 1;
        //    myOraclizeUpdateBook();
        //}
        
        myOraclizeGetVerse();
    }
    
    /**
    * @dev This is the  minting function that updates the data structures relating to ownership when minting a BibleToken.
    */
    function _mint(
        address _to,
        uint256 _tokenIndex
    )
        internal
    {
        require(_to != address(0));
        require(_tokenIndex != 0);
        require(indexToOwner[_tokenIndex] == address(0));

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
    * @dev This function constructs the URL in the Oraclize query to retrieve the Bible verse text.
    */
    function constructVerseTextURL()
        internal
        view
        returns (string)
    {
        bytes memory burl_1 = bytes(urlVerseI);
        bytes memory burl_2 = bytes(currentBookName);
        bytes memory burl_3 = bytes(urlVerseII);
        bytes memory burl_4 = bytes(uint2str(currentChapterNumber));
        bytes memory burl_5 = bytes(urlVerseIII);
        bytes memory burl_6 = bytes(uint2str(currentVerseNumber));
        bytes memory burl_7 = bytes(urlVerseIV);
        
        string memory url = new string(getLengthVerseTextURL(burl_2, burl_4, burl_6));
        bytes memory burl = bytes(url);
            
        uint i = 0;
        uint k = 0;
        for (i = 0; i < burl_1.length; i++) burl[k++] = burl_1[i];
        for (i = 0; i < burl_2.length; i++) burl[k++] = burl_2[i];
        for (i = 0; i < burl_3.length; i++) burl[k++] = burl_3[i];
        for (i = 0; i < burl_4.length; i++) burl[k++] = burl_4[i];
        for (i = 0; i < burl_5.length; i++) burl[k++] = burl_5[i];
        for (i = 0; i < burl_6.length; i++) burl[k++] = burl_6[i];
        for (i = 0; i < burl_7.length; i++) burl[k++] = burl_7[i];
        
        url = string(burl);
        return url;
    }
    
    /**
    * @dev This function constructs the URL in the Oraclize query to update the data for calculating the next Oraclize query.
    */
    function constructChapterVersesURL(
        string _currentBookName
    )
        internal
        view
        returns (string)
    {
        bytes memory burl_1 = bytes(urlChapterVersesI);
        bytes memory burl_2 = bytes(_currentBookName);
        bytes memory burl_3 = bytes(urlChapterVersesII);
        bytes memory burl_4 = bytes(_currentBookName);
        bytes memory burl_5 = bytes(urlChapterVersesIII);
        
        string memory url = new string(getLengthChapterVersesURL(burl_2, burl_4));
        bytes memory burl = bytes(url);
            
        uint i = 0;
        uint k = 0;
        for (i = 0; i < burl_1.length; i++) burl[k++] = burl_1[i];
        for (i = 0; i < burl_2.length; i++) burl[k++] = burl_2[i];
        for (i = 0; i < burl_3.length; i++) burl[k++] = burl_3[i];
        for (i = 0; i < burl_4.length; i++) burl[k++] = burl_4[i];
        for (i = 0; i < burl_5.length; i++) burl[k++] = burl_5[i];
        
        url = string(burl);
        return url;
    }
    
    /**
    * @dev This supplemental function is needed due to current Solidity stack size limitations when adding multiple numbers.
    * This one is unique to it's corresponding constructVerseTextURL function.
    */
    function getLengthVerseTextURL(
        bytes _currentBookName,
        bytes _currentChapterNumber,
        bytes _currentVerseNumber
    )
        internal
        view
        returns (uint256)
    {
        uint256 length = 0;
        length += bytes(urlVerseI).length + bytes(urlVerseII).length + bytes(urlVerseII).length + bytes(urlVerseIV).length;
        length += _currentBookName.length + _currentChapterNumber.length + _currentVerseNumber.length;
        return length;
    }
    
    /**
    * @dev This supplemental function is needed due to current Solidity stack size limitations when adding multiple numbers.
    * This one is unique to it's corresponding constructChapterVersesURL function.
    */
    function getLengthChapterVersesURL(
        bytes _currentBookNameI,
        bytes _currentBookNameII
    )
        internal
        view
        returns (uint256)
    {
        uint length = 0;
        length += bytes(urlChapterVersesI).length + bytes(urlChapterVersesII).length + bytes(urlChapterVersesIII).length;
        length += _currentBookNameI.length + _currentBookNameII.length;
        return length;
    }
    
    /**
    * @dev 
    */
    function myOraclizeGetVerse()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        bytes32 id = oraclize_query("IPFS", currentURL);
        OraclizeQuery("Query sent; awaiting response...");
        queryIds[id] = msg.sender;
    }
    
    /**
    * @dev The purpose of this function is that when the program state recognizes that it has
    * run out of chapters to process (and has not come to the end of the Bible) it will call
    * this function to retrieve the data for the next book.
    * This data will include: the name of the book, and the array of chapter verses.
    */
    function myOraclizeUpdateBook()
        internal
    {
        ++booksCompleted;
        currentBookName = booksOfTheBible[booksCompleted];
        myOraclizeGetChapterVerses(booksOfTheBible[booksCompleted]);
        currentURL = constructVerseTextURL();
    }
    
    /**
    * @dev 
    */
    function myOraclizeGetChapterVerses(
        string _book
    )
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        string memory url = constructChapterVersesURL(_book);
        oraclize_query("IPFS", url);
        OraclizeQuery("Query sent; awaiting response...");
    }
}
