pragma solidity ^0.4.20;

import "./BibleTokenMinting.sol";

/**
 * @dev 
 */
contract BibleTokenCore is BibleTokenMinting {
    
    /**
     * @dev 
     */
    function BibleTokenCore()
        public
    {
        booksCompleted = 0;
        currentBookName = booksOfTheBible[booksCompleted];
        currentChapterVerses = [
            31, 25, 24, 26, 32, 22, 24, 22, 29, 32,
            32, 20, 18, 24, 21, 16, 27, 33, 38, 18,
            34, 24, 20, 67, 34, 35, 46, 22, 35, 43,
            55, 32, 20, 31, 29, 43, 36, 30, 23, 23,
            57, 38, 34, 34, 28, 34, 31, 22, 33, 26
        ];
        
        currentChapterNumber = 1;
        currentVerseNumber = 1;
        currentURL = constructVerseTextURL();
    }
    
    /**
     * @dev 
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
     * @dev 
     */
    function withdrawBalance() external onlyOwner {
        uint256 balance = this.balance;
        require(balance > 0);
        owner.send(balance);
    }
}
