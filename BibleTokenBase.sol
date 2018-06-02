pragma solidity ^0.4.20;

/**
 * @dev The base contract holding all the data unique to this contract.
 */
contract BibleTokenBase {
    /*** EVENTS ***/

    // event VerseMinted(address indexed _owner, uint256 _verseId);

    /*** DATA TYPES ***/

    struct Token {
        string bookName;
        uint8  chapterNumber;
        uint8  verseNumber;
        string verseText;
    }

    /*** CONSTANTS ***/

    /// @dev Constants of non-value type are not yet supported, otherwise these would be constant
    //string[] internal booksOfTheBible = [
    //    "Gensis",           "Exodus",           "Leviticus",
    //    "Numbers",          "Deuteronomy",      "Joshua",
    //    "Judges",           "Ruth",             "1 Samuel",
    //    "2 Samuel",         "1 Kings",          "2 Kings",
    //    "1 Chronicles",     "2 Chronicles",     "Ezra",
    //    "Nehemiah",         "Esther",           "Job",
    //    "Psalms",           "Proverbs",         "Ecclesiastes",
    //    "Song of Solomon",  "Isaiah",           "Jeremiah",
    //    "Lamentation",      "Ezekiel",          "Daniel",
    //    "Hosea",            "Joel",             "Amos",
    //    "Obadiah",          "Jonah",            "Micah",
    //    "Nahum",            "Habakkuk",         "Zephaniah",
    //    "Haggai",           "Zechariah",        "Malachi",
    //    "Matthew",          "Mark",             "Luke",
    //    "John",             "Acts",             "Romans",
    //    "1 Corinthians",    "2 Corinthians",    "Galatians",
    //    "Ephesians",        "Philippians",      "Colossians",
    //    "1 Thessalonians",  "2 Thessalonians",  "1 Timothy",
    //    "2 Timothy",        "Titus",            "Philemon",
    //    "Hebrews",          "James",            "1 Peter",
    //    "2 Peter",          "1 John",           "2 John",
    //    "3 John",           "Jude",             "Revelation"
    //];
    
    uint8 constant internal totalBooks = 66;

    // Base url for the verseText query
    string constant internal urlVerseI      = "xml(QmTwuWLqJHvcrV3NokMiFSRoadcA8AY5C3FWHBDXtKwZrp).xpath(/Bible/Book[@name='";
    string constant internal urlVerseII     = "']/Chapter[@id='";
    string constant internal urlVerseIII    = "']/Verse[@id='";
    string constant internal urlVerseIV     = "']/text())";

    // Base url for the  currentChapterVerses query
    string constant internal urlChapterVersesI      = "xml(QmTwuWLqJHvcrV3NokMiFSRoadcA8AY5C3FWHBDXtKwZrp).xpath(/Bible/Book[@name='";
    string constant internal urlChapterVersesII    = "']/Chapter/numberOfVerses/text())";

    /*** STORAGE ***/

    // // The array to hold all of the tokens (verses of The Bible)
    // Token[] internal tokens;

    // // Mapping from token ID to owner
    // mapping (uint256 => address) internal tokenOwner;

    // // Mapping from owner to number of owned token
    // mapping (address => uint256) internal ownedTokensCount;

    // // Mapping from owner to list of owned token IDs
    // mapping (address => uint256[]) internal ownedTokens;

    // // Mapping from token ID to approved address
    // mapping (uint256 => address) internal tokenApprovals;

    // // Mapping from owner to operator approvals
    // mapping (address => mapping (address => bool)) internal operatorApprovals;
    
    //uint8[] public currentChapterVerses;
    
    uint8  public booksCompleted;
    
    string public currentBookName;
    uint8  public currentNumberOfChapters;
    uint8  public currentChapterVersesNumber;
    uint8  public currentChapterNumber;
    uint8  public currentVerseNumber;
    
    string public currentURL;
}
