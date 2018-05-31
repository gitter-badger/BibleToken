pragma solidity ^0.4.20;

/**
 * @dev ERC-721 interface for accepting safe transfers. See https://goo.gl/pc9yoS.
 */
interface ERC721TokenReceiver {

    /**
    * @dev Handle the receipt of a NFT. The ERC721 smart contract calls this function on the
    * recipient after a `transfer`. This function MAY throw to revert and reject the transfer. This
    * function MUST use 50,000 gas or less. Return of other than the magic value MUST result in the
    * transaction being reverted. Returns `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
    * unless throwing.
    * @notice The contract address is always the message sender. A wallet/broker/auction application
    * MUST implement the wallet interface if it will accept safe transfers.
    * @param _from The sending address.
    * @param _tokenId The NFT identifier which is being transfered.
    * @param _data Additional data with no specified format.
    */
    function onERC721Received(
        address _from,
        uint256 _tokenId,
        bytes _data
    )
        external
        returns(bytes4);
}
