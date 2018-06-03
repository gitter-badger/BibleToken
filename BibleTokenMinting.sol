pragma solidity ^0.4.20;

import "./BibleTokenEnumerable.sol";
import "./Oraclize.sol";

// TODO make test data to test minting logic offline quickly
// TODO figure out the appropriate gas cost for the Oraclize queries
// TODO figure out how to effectively pause the contract during Book/Chapter state updates
// TODO figure out if an auction contract is needed to be able to more easily transfer tokens around through an API on the website

contract BibleTokenMinting is BibleTokenEnumerable, usingOraclize {
    
    /**
    * @dev 
    */
    enum QueryType {GET_VERSE, GET_CHAPTER_VERSES, GET_BOOK_NAME, GET_NUMBER_OF_CHAPTERS}
    
    /**
    * @dev 
    */
    mapping (bytes32 => QueryType) queryToType;
    
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
        require(booksCompleted < totalBooks);
        _;
    }
    
    /**
    * @dev This mapping is very important; without it, there would be no way for a BibleToken to get minted to any address.
    * Thus this mappng is used to keep track of the query Ids and their associated addresses (msg.sender).
    * The Id will get written to this mapping on a successfull query. And will then get deleted upon completion of the minting process.
    */
    mapping (bytes32 => address) queryToSender;
    
    /**
    * @dev This is where all the minting action takes place. Since a BibleToken cannot be minted
    * unless it has the appropriate data, and that is only possible after the Oraclize query.
    * Thus when someone calls the mint function, they will have to wait until Oraclize processes the query
    * before they can access their BibleToken; which should take at most a couple minutes.
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
            //unpause();
            //Unpause();
        } else if(queryToType[_myid] == QueryType.GET_CHAPTER_VERSES) {
            _updateChapterVerses(_myid, _result);
            //unpause();
            //Unpause();
        } else if(queryToType[_myid] == QueryType.GET_BOOK_NAME) {
            _updateBookName(_myid, _result);
            //unpause();
            //Unpause();
        } else if(queryToType[_myid] == QueryType.GET_NUMBER_OF_CHAPTERS) {
            _updateNumberOfChapters(_myid, _result);
            //unpause();
            //Unpause();
        } else {
            revert(); // ?
        }
    }
    
    /**
    * @dev 
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
    * @dev 
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
    * @dev 
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
    * @dev 
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
    * @dev 
    */
    function update()
        internal
    {
        updateVerse();
    }
    
    /**
    * @dev 
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
    * @dev 
    */
    function updateChapter()
        internal
    {
        currentVerseNumber = 1;
        ++currentChapterNumber;
        if(currentChapterNumber > currentNumberOfChapters) {
            updateBook();
        } else {
            //pause();
            //Pause();
            myOraclizeUpdateChapterVerses();
        }
    }
    
    /**
    * @dev 
    */
    function updateBook()
        internal
    {
        currentChapterNumber = 1;
        if((booksCompleted + 1) < totalBooks) {
            //pause();
            //Pause();
            myOraclizeUpdateBookName();
            myOraclizeUpdateNumberOfChapters();
            myOraclizeUpdateChapterVerses();
            ++booksCompleted;
        } else {
            delete currentBookName;
            delete currentNumberOfChapters;
            delete currentChapterVersesNumber;
            delete currentChapterNumber;
            delete currentVerseNumber;
            //delete currentURL;
            return;
        }
    }
    
    /**
    * @dev 
    */
    function myOraclizeUpdateChapterVerses()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory url = "xml(QmadTRozysyYSvWSqVZgZsCH2rUWKF1zVKTXpMC3mm9xih).xpath(/Bible/Book[@id='";
        
        url = strConcat(
            url,
            uint2str(booksCompleted + 1),
            "']/Chapter[@id='",
            uint2str(currentChapterNumber),
            "']/numberOfVerses/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", url, 5000000);
        queryToType[id] = QueryType.GET_CHAPTER_VERSES;
        
        OraclizeQuery("Query sent; awaiting response...");
    }
    
    /**
    * @dev 
    */
    function myOraclizeUpdateBookName()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory url = "xml(QmadTRozysyYSvWSqVZgZsCH2rUWKF1zVKTXpMC3mm9xih).xpath(/Bible/Book[@id='";
        
        url = strConcat(
            url,
            uint2str(booksCompleted + 2),
            "']/bookName/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", url, 5000000);
        queryToType[id] = QueryType.GET_BOOK_NAME;
        
        OraclizeQuery("Query sent; awaiting response...");
    }
    
    /**
    * @dev 
    */
    function myOraclizeUpdateNumberOfChapters()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory url = "xml(QmadTRozysyYSvWSqVZgZsCH2rUWKF1zVKTXpMC3mm9xih).xpath(/Bible/Book[@id='";
        
        url = strConcat(
            url,
            uint2str(booksCompleted + 2),
            "']/numberOfChapters/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", url, 5000000);
        queryToType[id] = QueryType.GET_NUMBER_OF_CHAPTERS;
        
        OraclizeQuery("Query sent; awaiting response...");
    }
    
    /**
    * @dev 
    */
    function myOraclizeMintVerse()
        internal
    {
        require(this.balance > oraclize_getPrice("IPFS"));
        
        string memory url = "xml(QmadTRozysyYSvWSqVZgZsCH2rUWKF1zVKTXpMC3mm9xih).xpath(/Bible/Book[@id='";
        
        url = strConcat(
            url,
            uint2str(booksCompleted + 1),
            "']/Chapter[@id='",
            uint2str(currentChapterNumber),
            "']/Verse[@id='"
        );
        url = strConcat(
            url,
            uint2str(currentVerseNumber),
            "']/text())"
        );
        
        bytes32 id = oraclize_query("IPFS", url, 5000000);
        queryToType[id] = QueryType.GET_VERSE;
        queryToSender[id] = msg.sender;
        
        OraclizeQuery("Query sent; awaiting response...");
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
        //whenNotPaused
        booksIncomplete
    {
        require(msg.value == 0.25 ether);
        //pause();
        //Pause();
        myOraclizeMintVerse();
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
        assert(_to != address(0));
        //require(_tokenIndex != 0);
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
    * @dev 
    */
    //function parseChapterVersesQueryResponse(
    //    string _stringArr
    //)
    //    internal
    //{
    //    // The variable for holding the quote count.
    //    // If the quote count is equal to 2, then the temp string gets parsed into an int and pushed to the currentChapterVerses array.
    //    uint8 quoteCount = 0;
    //    // The variable to hold the number that is to be parsed to an int.
    //    string memory digits;
    //    
    //    bytes memory bytesArr = bytes(_stringArr);
    //    byte char;
    //    for(uint8 i = 0; i < bytesArr.length; ++i) {
    //        char = bytesArr[i];
    //        if(char == 0x5d) break;
    //        if(char == 0x5b ||  char == 0x2c || char == 0x20) continue;
    //        if(char == 0x22) {
    //            ++quoteCount;
    //            if(quoteCount == 2) {
    //                //currentChapterVerses.push(uint8(parseInt(digits)));
    //                delete digits;
    //                quoteCount = 0;
    //            }
    //        }
    //        string memory temp = bytes8ToString(bytes8(char));
    //        digits = strConcat(digits, string(temp));
    //    }
    //}
    
    /**
    * @dev 
    */
    //function bytes8ToString(
    //    bytes8 x
    //)
    //    public
    //    returns (string)
    //{
    //    bytes memory bytesString = new bytes(8);
    //    uint charCount = 0;
    //    for (uint j = 0; j < 8; j++) {
    //        byte char = byte(bytes8(uint(x) * 2 ** (8 * j)));
    //        if (char != 0) {
    //            bytesString[charCount] = char;
    //            charCount++;
    //        }
    //    }
    //    bytes memory bytesStringTrimmed = new bytes(charCount);
    //    for (j = 0; j < charCount; j++) {
    //        bytesStringTrimmed[j] = bytesString[j];
    //    }
    //        return string(bytesStringTrimmed);
    //}
    
    /**
    * @dev 
    */
    //function updateURL()
    //    internal
    //{
    //    if(!(currentVerseNumber < currentChapterVersesNumber)) {
    //        currentVerseNumber = 1;
    //        ++currentChapterNumber;
    //    }
    //    
    //    if(!(currentChapterNumber < currentNumberOfChapters)) {
    //        currentChapterNumber = 1;
    //        //myOraclizeUpdateBook();
    //    } else {
    //        currentURL = constructVerseTextURL();
    //    }
    //}
    
    /**
    * @dev This function constructs the URL in the Oraclize query to retrieve the Bible verse text.
    */
    //function constructVerseTextURL()
    //    internal
    //    view
    //    returns (string)
    //{
    //    bytes memory burl_1 = bytes(urlVerseI);
    //    bytes memory burl_2 = bytes(currentBookName);
    //    bytes memory burl_3 = bytes(urlVerseII);
    //    bytes memory burl_4 = bytes(uint2str(currentChapterNumber));
    //    bytes memory burl_5 = bytes(urlVerseIII);
    //    bytes memory burl_6 = bytes(uint2str(currentVerseNumber));
    //    bytes memory burl_7 = bytes(urlVerseIV);
    //    
    //    string memory url = new string(getLengthVerseTextURL(burl_2, burl_4, burl_6));
    //    bytes memory burl = bytes(url);
    //        
    //    uint i = 0;
    //    uint k = 0;
    //    for (i = 0; i < burl_1.length; i++) burl[k++] = burl_1[i];
    //    for (i = 0; i < burl_2.length; i++) burl[k++] = burl_2[i];
    //    for (i = 0; i < burl_3.length; i++) burl[k++] = burl_3[i];
    //    for (i = 0; i < burl_4.length; i++) burl[k++] = burl_4[i];
    //    for (i = 0; i < burl_5.length; i++) burl[k++] = burl_5[i];
    //    for (i = 0; i < burl_6.length; i++) burl[k++] = burl_6[i];
    //    for (i = 0; i < burl_7.length; i++) burl[k++] = burl_7[i];
    //    
    //    url = string(burl);
    //    return url;
    //}
    
    /**
    * @dev This function constructs the URL in the Oraclize query to update the data for calculating the next Oraclize query.
    */
    //function constructChapterVersesURL(
    //    string _currentBookName
    //)
    //    internal
    //    view
    //    returns (string)
    //{
    //    bytes memory burl_1 = bytes(urlChapterVersesI);
    //    bytes memory burl_2 = bytes(_currentBookName);
    //    bytes memory burl_3 = bytes(urlChapterVersesII);
    //    
    //    string memory url = new string(getLengthChapterVersesURL(burl_2));
    //    bytes memory burl = bytes(url);
    //        
    //    uint i = 0;
    //    uint k = 0;
    //    for (i = 0; i < burl_1.length; i++) burl[k++] = burl_1[i];
    //    for (i = 0; i < burl_2.length; i++) burl[k++] = burl_2[i];
    //    for (i = 0; i < burl_3.length; i++) burl[k++] = burl_3[i];
    //    
    //    url = string(burl);
    //    return url;
    //}
    
    /**
    * @dev This supplemental function is needed due to current Solidity stack size limitations when adding multiple numbers.
    * This one is unique to it's corresponding constructVerseTextURL function.
    */
    //function getLengthVerseTextURL(
    //    bytes _currentBookName,
    //    bytes _currentChapterNumber,
    //    bytes _currentVerseNumber
    //)
    //    internal
    //    view
    //    returns (uint256)
    //{
    //    uint256 length = 0;
    //    length += bytes(urlVerseI).length + bytes(urlVerseII).length + bytes(urlVerseII).length + bytes(urlVerseIV).length;
    //    length += _currentBookName.length + _currentChapterNumber.length + _currentVerseNumber.length;
    //    return length;
    //}
    
    /**
    * @dev This supplemental function is needed due to current Solidity stack size limitations when adding multiple numbers.
    * This one is unique to it's corresponding constructChapterVersesURL function.
    */
    //function getLengthChapterVersesURL(
    //    bytes _currentBookName
    //)
    //    internal
    //    view
    //    returns (uint256)
    //{
    //    uint length = 0;
    //    length += bytes(urlChapterVersesI).length + bytes(urlChapterVersesII).length;
    //    length += _currentBookName.length;
    //    return length;
    //}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Ownership ---------------------------------------------------------------------------------------------------------
    /**
    * @dev Mints a new NFT.
    * @notice This is a private function which should be called from user-implemented external
    * mint function. Its purpose is to show and properly initialize data structures when using this
    * implementation.
    * @param _to The address that will own the minted NFT.
    * @param _tokenId of the NFT to be minted by the msg.sender.
    */
    //function _mint(
    //    address _to,
    //    uint256 _tokenId
    //)
    //    internal
    //{
    //    require(_to != address(0));
    //    require(_tokenId != 0);
    //    require(idToOwner[_tokenId] == address(0));

    //    addNFToken(_to, _tokenId);

    //    emit Transfer(address(0), _to, _tokenId);
    //}

    /**
    * @dev Burns a NFT.
    * @notice This is a private function which should be called from user-implemented external
    * burn function. Its purpose is to show and properly initialize data structures when using this
    * implementation.
    * @param _owner Address of the NFT owner.
    * @param _tokenId ID of the NFT to be burned.
    */
    //function _burn(
    //    address _owner,
    //    uint256 _tokenId
    //)
    //    validNFToken(_tokenId)
    //    internal
    //{
    //    clearApproval(_owner, _tokenId);
    //    removeNFToken(_owner, _tokenId);
    //    emit Transfer(_owner, address(0), _tokenId);
    //}
    // End Ownership -----------------------------------------------------------------------------------------------------
    
    // Enumerable --------------------------------------------------------------------------------------------------------
    /**
    * @dev Mints a new NFT.
    * @notice This is a private function which should be called from user-implemented external
    * mint function. Its purpose is to show and properly initialize data structures when using this
    * implementation.
    * @param _to The address that will own the minted NFT.
    * @param _tokenId of the NFT to be minted by the msg.sender.
    */
    //function _mint(
    //    address _to,
    //    uint256 _tokenId
    //)
    //    internal
    //{
    //    super._mint(_to, _tokenId);
    //    tokens.push(_tokenId);
    //}

    /**
    * @dev Burns a NFT.
    * @notice This is a private function which should be called from user-implemented external
    * burn function. Its purpose is to show and properly initialize data structures when using this
    * implementation.
    * @param _owner Address of the NFT owner.
    * @param _tokenId ID of the NFT to be burned.
    */
    //function _burn(
    //    address _owner,
    //    uint256 _tokenId
    //)
    //    internal
    //{
    //    assert(tokens.length > 0);
    //    super._burn(_owner, _tokenId);

    //    uint256 tokenIndex = idToIndex[_tokenId];
    //    uint256 lastTokenIndex = tokens.length.sub(1);
    //    uint256 lastToken = tokens[lastTokenIndex];

    //    tokens[tokenIndex] = lastToken;
    //    tokens[lastTokenIndex] = 0;

    //    tokens.length--;
    //    idToIndex[_tokenId] = 0;
    //    idToIndex[lastToken] = tokenIndex;
    //}
    
    /**
    * @dev Removes a NFT from an address.
    * @notice Use and override this function with caution. Wrong usage can have serious consequences.
    * @param _from Address from wich we want to remove the NFT.
    * @param _tokenId Which NFT we want to remove.
    */
    //function removeNFToken(
    //    address _from,
    //    uint256 _tokenId
    //)
    //internal
    //{
    //    super.removeNFToken(_from, _tokenId);
    //    assert(ownerToIds[_from].length > 0);

    //    uint256 tokenToRemoveIndex = idToOwnerIndex[_tokenId];
    //    uint256 lastTokenIndex = ownerToIds[_from].length.sub(1);
    //    uint256 lastToken = ownerToIds[_from][lastTokenIndex];

    //    ownerToIds[_from][tokenToRemoveIndex] = lastToken;
    //    ownerToIds[_from][lastTokenIndex] = 0;

    //    ownerToIds[_from].length--;
    //    idToOwnerIndex[_tokenId] = 0;
    //    idToOwnerIndex[lastToken] = tokenToRemoveIndex;
    //}

    /**
    * @dev Assignes a new NFT to an address.
    * @notice Use and override this function with caution. Wrong usage can have serious consequences.
    * @param _to Address to wich we want to add the NFT.
    * @param _tokenId Which NFT we want to add.
    */
    //function addNFToken(
    //    address _to,
    //    uint256 _tokenId
    //)
    //    internal
    //{
    //    super.addNFToken(_to, _tokenId);

    //    uint256 length = ownerToIds[_to].length;
    //    ownerToIds[_to].push(_tokenId);
    //    idToOwnerIndex[_tokenId] = length;
    //}
    // End Enumerable ----------------------------------------------------------------------------------------------------
    
    // Metadata ----------------------------------------------------------------------------------------------------------
    /**
    * @dev Burns a NFT.
    * @notice This is a internal function which should be called from user-implemented external
    * burn function. Its purpose is to show and properly initialize data structures when using this
    * implementation.
    * @param _owner Address of the NFT owner.
    * @param _tokenId ID of the NFT to be burned.
    */
    //function _burn(
    //    address _owner,
    //    uint256 _tokenId
    //)
    //    internal
    //{
    //    super._burn(_owner, _tokenId);

    //    if (bytes(idToUri[_tokenId]).length != 0) {
    //        delete idToUri[_tokenId];
    //    }
    //}
    // End Metadata ------------------------------------------------------------------------------------------------------
}