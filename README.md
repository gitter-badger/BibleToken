BibleToken - Getting The Bible on The Blockchain
================================================

< website-goes-here >

What is BibleToken?
-------------------
The BibleToken project aims to get The King James Bible onto the Ethereum blockchain.
Which means it will remain immutable and accessible to anyone in the world for as long as the internet exists!

Isn't Storing Anything on The Blockchain Extremely Expensive?
-------------------------------------------------------------
Valid question.
To simply hard-code the Bible onto the Ethereum blockchain would cost quite a bit.
Just storing one 256 bit word costs 20,000 gas (the unit of currency on which the Ethereum blockchain runs on).
With the current cost of gas, that would be $0.097 per 256 bit word.

And with the Bible being 4,332,914 bytes in size.
Storing it would cost: 4,332,914 * 0.097 = $420,292.66

So How Are We Going To Store The Bible?
---------------------------------------
Using the ERC721 token standard (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) we can mint
the entire Bible onto the blockchain, and while doing so a total of 31,102 (the number of verses in The
King James Bible) unique tokens will be produced for anyone to collect as digital collectables and to freely trade if you so choose.

The ERC721 token standard defines a set of rules for non-fungible (unique) tokens.
This will add an incentive for anyone who wants to help get the Bible on the blockchain.

Each time you mint a token, the corresponding verse will get written to the blockchain,
and you will receive a token signifying that unique verse to the address you minted it from.
The data for each verse comes from an immutable XML file stored on the IPFS that will be retrieved using the Oraclize API.

The tokens will be getting minted incrementally, starting from Genesis 1:1 and ending in Revelation 22:21.
This is to keep people from greedily minting any verse they want for themselves.
This way, it will also build anticipation for people watching to see when one of their favorite verses will get minted.

Once the token is minted, you (and anyone else in the world) will be able to view that verse for no gas cost.

How Can I Help?
---------------
Any help auditing the code for security holes or organizing the logic of the code as well as a number of many other things would be greatly appreciated.

This is going to have to be a community effort.

Let's get the Bible on the blockchain!
