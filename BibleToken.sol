pragma solidity ^0.4.18;

import "./ERC721Token.sol";
import "./Oraclize/usingOraclize.sol";

contract BibleToken is ERC721Token, usingOraclize {
    
    // @dev explanation here
    struct Token {
        string bookName;
        uint8  chapterNumber;
        uint8  verseNumber;
        string verseText;
    }
    
    string[] public booksOfTheBible = [
        "Gensis",           "Exodus",           "Leviticus",
        "Numbers",          "Deuteronomy",      "Joshua",
        "Judges",           "Ruth",             "1 Samuel",
        "2 Samuel",         "1 Kings",          "2 Kings",
        "1 Chronicles",     "2 Chronicles",     "Ezra",
        "Nehemiah",         "Esther",           "Job",
        "Psalms",           "Proverbs",         "Ecclesiastes",
        "Song of Solomon",  "Isaiah",           "Jeremiah",
        "Lamentation",      "Ezekiel",          "Daniel",
        "Hosea",            "Joel",             "Amos",
        "Obadiah",          "Jonah",            "Micah",
        "Nahum",            "Habakkuk",         "Zephaniah",
        "Haggai",           "Zechariah",        "Malachi",
        "Matthew",          "Mark",             "Luke",
        "John",             "Acts",             "Romans",
        "1 Corinthians",    "2 Corinthians",    "Galatians",
        "Ephesians",        "Philippians",      "Colossians",
        "1 Thessalonians",  "2 Thessalonians",  "1 Timothy",
        "2 Timothy",        "Titus",            "Philemon",
        "Hebrews",          "James",            "1 Peter",
        "2 Peter",          "1 John",           "2 John",
        "3 John",           "Jude",             "Revelation"
    ];
    
    // @dev explanation here
    uint8  constant internal urlBaseSize = 117;
    string constant internal urlBaseI    = "xml(QmZSjsND17sEbSPzyMub1czPbr1rXttTiCG6pN1znFz7wa).xpath(/Bible/Book[@name='";
    string constant internal urlBaseII   = "']/Chapter[@id='";
    string constant internal urlBaseIII  = "']/Verse[@id='";
    string constant internal urlBaseIV   = "']/text())";
    
    // @dev explanation here
    // The array to hold all of the tokens (verses of The Bible)
    Token[] tokens;

    // @dev explanation here
    string  public currentBookName;
    uint8[] public currentChapterVerses;
    uint8   public currentChapterNumber;
    uint8   public currentVerseNumber;
    
    // @dev explanation here
    string  public currentURL;
    
    // @dev explanation here
    uint8   public booksCompleted;
    
    // @dev explanation here
    event OraclizeQuery(string description);
    event RetrievedVerse(string verse);
    
    // @dev explanation here
    modifier booksIncomplete () {
        require(booksCompleted < booksOfTheBible.length);
        _;
    }
    
    // @dev explanation here
    function BibleToken() public {
        // @dev explanation here
        booksCompleted       = 0;
        currentBookName      = booksOfTheBible[booksCompleted];
        currentChapterVerses = [
            31, 25, 24, 26, 32, 22, 24, 22, 29, 32,
            32, 20, 18, 24, 21, 16, 27, 33, 38, 18,
            34, 24, 20, 67, 34, 35, 46, 22, 35, 43,
            55, 32, 20, 31, 29, 43, 36, 30, 23, 23,
            57, 38, 34, 34, 28, 34, 31, 22, 33, 26
        ];
        
        // @dev explanation here
        currentChapterNumber = 1;
        currentVerseNumber   = 1;
        
        // @dev explanation here
        currentURL           = constructURL();
    }
    
    // @dev explanation here
    function mint()payable public booksIncomplete returns (uint256) {
        // @dev explanation here
        if(!(currentVerseNumber < currentChapterVerses[currentChapterNumber])) {
            currentVerseNumber = 1;
            ++currentChapterNumber;
        }
        
        // @dev explanation here
        if(!(currentChapterNumber < currentChapterVerses.length)) {
            currentChapterNumber = 1;
            myOraclizeUpdateBook();
        }
        
        // @dev explanation here
        string memory text = "ok" /* This is the actual function to be implemented myOraclizeGetVerse()*/;
        
        // @dev explanation here
        Token memory token = Token({
            bookName:      currentBookName,
            chapterNumber: currentChapterNumber,
            verseNumber:   currentVerseNumber,
            verseText:     text
        });
        
        // @dev explanation here
        uint256 tokenId = tokens.push(token) - 1;
        ++currentVerseNumber;
        return tokenId;
    }
    
    // @dev explanation here
    function retrieveVerse(string _book, uint8 _chapter, uint8 _verse) view public returns (string) {
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
        // TODO find a better string to return than this one
        return "Verse not minted yet, or invalid Book Name.";
    }
    
    // @dev explanation here
    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        //ret = result;
        
        RetrievedVerse(result);
    }
    
    // @dev explanation here
    function constructURL() internal view returns (string) {
        bytes memory burl_1 = bytes(urlBaseI);
        bytes memory burl_2 = bytes(currentBookName);
        bytes memory burl_3 = bytes(urlBaseII);
        bytes memory burl_4 = bytes(uint2str(currentChapterNumber));
        bytes memory burl_5 = bytes(urlBaseIII);
        bytes memory burl_6 = bytes(uint2str(currentVerseNumber));
        bytes memory burl_7 = bytes(urlBaseIV);
            
        // TODO possibly split the count into another function
        // TODO possibly split the constant size of the url in another function
        //      just in case the constant url need to change in the future
        string memory url = new string(urlBaseSize + burl_2.length + burl_4.length + burl_6.length);
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
    
    // @dev the purpose of this function is that when the program state recognizes that it has
    //  run out of chapters to process (and has not come to the end of the Bible) it will call
    //  this function to retrieve the data for the next book.
    //  This data will include: the name of the book, and the array of chapter verses.
    function myOraclizeUpdateBook() internal {
        ++booksCompleted;
        currentBookName = booksOfTheBible[booksCompleted];
        
        myOraclizeGetChapterVerses(booksOfTheBible[booksCompleted]);
        // Parse the response in the __callback
        
        currentChapterVerses = [
            31, 25, 24, 26, 32, 22, 24, 22, 29, 32,
            32, 20, 18, 24, 21, 16, 27, 33, 38, 18,
            34, 24, 20, 67, 34, 35, 46, 22, 35, 43,
            55, 32, 20, 31, 29, 43, 36, 30, 23, 23,
            57, 38, 34, 34, 28, 34, 31, 22, 33, 26
        ];
        
        currentURL = constructURL();
    }
    
    // @dev explanation here
    function myOraclizeGetChapterVerses(string _book) internal returns (string) {
        
    }
    
    // @dev explanation here
    function myOraclizeGetVerse() payable public {
        // Using this for debugging right now
        //return "ok";
        
        // The real Oraclize code
        //if (oraclize_getPrice("IPFS") > this.balance) {
        //    OraclizeQuery("Insufficient funds to send query");
        //} else {
        //    oraclize_query("IPFS", currentURL);
        //    
        //    OraclizeQuery("Query sent; awaiting response...");
        //}
    }
    
}

// Verse Text
// xml(QmZSjsND17sEbSPzyMub1czPbr1rXttTiCG6pN1znFz7wa).xpath(/Bible/Book[@name='Genesis']/Chapter[@id='1']/Verse[@id='1']/text())
// 
// Number of Chapters
// xml(QmZSjsND17sEbSPzyMub1czPbr1rXttTiCG6pN1znFz7wa).xpath(/Bible/Book[@name='Genesis']/numberOfChapters/text())
//
// Number of Chapter Verses
// xml(QmZSjsND17sEbSPzyMub1czPbr1rXttTiCG6pN1znFz7wa).xpath(/Bible/Book[@name='Genesis']/Chapter/numberOfVerses/text())
//
// The above two combined into one (the first element in the array is the Number of Chapters then follows the Number of Chapter Verses)
// xml(QmZSjsND17sEbSPzyMub1czPbr1rXttTiCG6pN1znFz7wa).xpath(/Bible/Book[@name='Genesis']/numberOfChapters/text() | /Bible/Book[@name='Genesis']/Chapter/numberOfVerses/text())
