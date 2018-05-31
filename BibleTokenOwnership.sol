pragma solidity ^0.4.20;

import "./math/SafeMath.sol";
import "./utils/AddressUtils.sol";

import "./ownership/Pausable.sol";
import "./ERC721.sol";
import "./SupportsInterface.sol";
import "./ERC721TokenReceiver.sol";

/**
 * @dev Implementation of ERC-721 non-fungible token standard.
 */
contract BibleTokenOwnership is Pausable, ERC721, SupportsInterface {
    using SafeMath for uint256;
    using AddressUtils for address;

    /**
    * @dev A mapping from NFT ID to the address that owns it.
    */
    mapping (uint256 => address) internal indexToOwner;

    /**
    * @dev Mapping from NFT ID to approved address.
    */
    mapping (uint256 => address) internal indexToApprovals;

    /**
    * @dev Mapping from owner address to count of his tokens.
    */
    mapping (address => uint256) internal ownerToBibleTokenCount;

    /**
    * @dev Mapping from owner address to mapping of operator addresses.
    */
    mapping (address => mapping (address => bool)) internal ownerToOperators;

    /**
    * @dev Magic value of a smart contract that can recieve NFT.
    */
    bytes4 constant MAGIC_ON_ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,uint256,bytes)")); // 0xf0b9e5ba;

    /**
    * @dev Emits when ownership of any NFT changes by any mechanism. This event emits when NFTs are
    * created (`from` == 0) and destroyed (`to` == 0). Exception: during contract creation, any
    * number of NFTs may be created and assigned without emitting Transfer. At the time of any
    * transfer, the approved address for that NFT (if any) is reset to none.
    * @param _from Sender of NFT (if address is zero address it indicates token creation).
    * @param _to Receiver of NFT (if address is zero address it indicates token destruction).
    * @param _tokenIndex The NFT that got transfered.
    */
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _tokenIndex
    );

    /**
    * @dev This emits when the approved address for an NFT is changed or reaffirmed. The zero
    * address indicates there is no approved address. When a Transfer event emits, this also
    * indicates that the approved address for that NFT (if any) is reset to none.
    * @param _owner Owner of NFT.
    * @param _approved Address that we are approving.
    * @param _tokenIndex NFT which we are approving.
    */
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 _tokenIndex
    );

    /**
    * @dev This emits when an operator is enabled or disabled for an owner. The operator can manage
    * all NFTs of the owner.
    * @param _owner Owner of NFT.
    * @param _operator Address to which we are setting operator rights.
    * @param _approved Status of operator rights(true if operator rights are given and false if
    * revoked).
    */
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /**
    * @dev Guarantees that the msg.sender is an owner or operator of the given NFT.
    * @param _tokenIndex ID of the NFT to validate.
    */
    modifier canOperate(
        uint256 _tokenIndex
    ) {
        address tokenOwner = indexToOwner[_tokenIndex];
        require(tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender]);
        _;
    }

    /**
    * @dev Guarantees that the msg.sender is allowed to transfer NFT.
    * @param _tokenIndex ID of the NFT to transfer.
    */
    modifier canTransfer(
        uint256 _tokenIndex
    ) {
        address tokenOwner = indexToOwner[_tokenIndex];
        require(
            tokenOwner == msg.sender
            || indexToApprovals[_tokenIndex] == msg.sender
            || ownerToOperators[tokenOwner][msg.sender]
            );
        _;
    }

    /**
    * @dev Guarantees that _tokenIndex is a valid Token.
    * @param _tokenIndex ID of the NFT to validate.
    */
    modifier validNFToken(
        uint256 _tokenIndex
    ) {
        require(indexToOwner[_tokenIndex] != address(0));
        _;
    }

    /**
    * @dev Contract constructor.
    */
    function BibleTokenOwnership()
        public
    {
        supportedInterfaces[bytes4(
            (keccak256("balanceOf(address)")) ^
            (keccak256("ownerOf(uint256)")) ^
            (keccak256("safeTransferFrom(address,address,uint256,bytes)")) ^
            (keccak256("safeTransferFrom(address,address,uint256)")) ^
            (keccak256("transferFrom(address,address,uint256)")) ^
            (keccak256("approve(address,uint256)")) ^
            (keccak256("setApprovalForAll(address,bool)")) ^
            (keccak256("getApproved(uint256)")) ^
            (keccak256("isApprovedForAll(address,address)")))] = true; // ERC721; 0x80ac58cd
    }

    /**
    * @dev Returns the number of NFTs owned by `_owner`. NFTs assigned to the zero address are
    * considered invalid, and this function throws for queries about the zero address.
    * @param _owner Address for whom to query the balance.
    */
    function balanceOf(
        address _owner
    )
        external
        view
        returns (uint256)
    {
        require(_owner != address(0));
        return ownerToBibleTokenCount[_owner];
    }

    /**
    * @dev Returns the address of the owner of the NFT. NFTs assigned to zero address are considered
    * invalid, and queries about them do throw.
    * @param _tokenIndex The identifier for an NFT.
    */
    function ownerOf(
        uint256 _tokenIndex
    )
        external
        view
        returns (address _owner)
    {
        _owner = indexToOwner[_tokenIndex];
        require(_owner != address(0));
    }

    /**
    * @dev Transfers the ownership of an NFT from one address to another address.
    * @notice Throws unless `msg.sender` is the current owner, an authorized operator, or the
    * approved address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is
    * the zero address. Throws if `_tokenId` is not a valid NFT. When transfer is complete, this
    * function checks if `_to` is a smart contract (code size > 0). If so, it calls `onERC721Received`
    * on `_to` and throws if the return value is not `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
    * @param _from The current owner of the NFT.
    * @param _to The new owner.
    * @param _tokenIndex The NFT to transfer.
    * @param _data Additional data with no specified format, sent in call to `_to`.
    */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenIndex,
        bytes _data
    )
        external
    {
        _safeTransferFrom(_from, _to, _tokenIndex, _data);
    }

    /**
    * @dev Transfers the ownership of an NFT from one address to another address.
    * @notice This works identically to the other function with an extra data parameter, except this
    * function just sets data to ""
    * @param _from The current owner of the NFT.
    * @param _to The new owner.
    * @param _tokenIndex The NFT to transfer.
    */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenIndex
    )
        external
    {
        _safeTransferFrom(_from, _to, _tokenIndex, "");
    }

    /**
    * @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
    * address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is the zero
    * address. Throws if `_tokenId` is not a valid NFT.
    * @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
    * they maybe be permanently lost.
    * @param _from The current owner of the NFT.
    * @param _to The new owner.
    * @param _tokenIndex The NFT to transfer.
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenIndex
    )
        external
        canTransfer(_tokenIndex)
        validNFToken(_tokenIndex)
    {
        address tokenOwner = indexToOwner[_tokenIndex];
        require(tokenOwner == _from);
        require(_to != address(0));

        _transfer(_to, _tokenIndex);
    }

    /**
    * @dev Set or reaffirm the approved address for an NFT.
    * @notice The zero address indicates there is no approved address. Throws unless `msg.sender` is
    * the current NFT owner, or an authorized operator of the current owner.
    * @param _approved Address to be approved for the given NFT ID.
    * @param _tokenIndex ID of the token to be approved.
    */
    function approve(
        address _approved,
        uint256 _tokenIndex
    )
        external
        canOperate(_tokenIndex)
        validNFToken(_tokenIndex)
    {
        address tokenOwner = indexToOwner[_tokenIndex];
        require(_approved != tokenOwner);
        require(!(indexToApprovals[_tokenIndex] == address(0) && _approved == address(0)));

        indexToApprovals[_tokenIndex] = _approved;
        Approval(tokenOwner, _approved, _tokenIndex);
    }

    /**
    * @dev Enables or disables approval for a third party ("operator") to manage all of
    * `msg.sender`'s assets. It also emits the ApprovalForAll event.
    * @notice This works even if sender doesn't own any tokens at the time.
    * @param _operator Address to add to the set of authorized operators.
    * @param _approved True if the operators is approved, false to revoke approval.
    */
    function setApprovalForAll(
        address _operator,
        bool _approved
    )
        external
    {
        require(_operator != address(0));
        ownerToOperators[msg.sender][_operator] = _approved;
        ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
    * @dev Get the approved address for a single NFT.
    * @notice Throws if `_tokenId` is not a valid NFT.
    * @param _tokenIndex ID of the NFT to query the approval of.
    */
    function getApproved(
        uint256 _tokenIndex
    )
        external
        view
        validNFToken(_tokenIndex)
        returns (address)
    {
        return indexToApprovals[_tokenIndex];
    }

    /**
    * @dev Checks if `_operator` is an approved operator for `_owner`.
    * @param _owner The address that owns the NFTs.
    * @param _operator The address that acts on behalf of the owner.
    */
    function isApprovedForAll(
        address _owner,
        address _operator
    )
        external
        view
        returns (bool)
    {
        require(_owner != address(0));
        require(_operator != address(0));
        return ownerToOperators[_owner][_operator];
    }

    /**
    * @dev Actually perform the safeTransferFrom.
    * @param _from The current owner of the NFT.
    * @param _to The new owner.
    * @param _tokenIndex The NFT to transfer.
    * @param _data Additional data with no specified format, sent in call to `_to`.
    */
    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenIndex,
        bytes _data
    )
        internal
        canTransfer(_tokenIndex)
        validNFToken(_tokenIndex)
    {
        address tokenOwner = indexToOwner[_tokenIndex];
        require(tokenOwner == _from);
        require(_to != address(0));

        _transfer(_to, _tokenIndex);

        if (_to.isContract()) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(_from, _tokenIndex, _data);
            require(retval == MAGIC_ON_ERC721_RECEIVED);
        }
    }

    /**
    * @dev Actually preforms the transfer.
    * @notice Does NO checks.
    * @param _to Address of a new owner.
    * @param _tokenIndex The NFT that is being transferred.
    */
    function _transfer(
        address _to,
        uint256 _tokenIndex
    )
        private
    {
        address from = indexToOwner[_tokenIndex];

        clearApproval(from, _tokenIndex);
        removeNFToken(from, _tokenIndex);
        addNFToken(_to, _tokenIndex);

        Transfer(from, _to, _tokenIndex);
    }

    /**
    * @dev Clears the current approval of a given NFT ID.
    * @param _tokenIndex ID of the NFT to be transferred.
    */
    function clearApproval(
        address _owner,
        uint256 _tokenIndex
    )
        internal
    {
        delete indexToApprovals[_tokenIndex];
        Approval(_owner, 0, _tokenIndex);
    }

    /**
    * @dev Removes a NFT from owner.
    * @notice Use and override this function with caution. Wrong usage can have serious consequences.
    * @param _from Address from wich we want to remove the NFT.
    * @param _tokenIndex Which NFT we want to remove.
    */
    function removeNFToken(
        address _from,
        uint256 _tokenIndex
    )
    internal
    {
        require(indexToOwner[_tokenIndex] == _from);
        assert(ownerToBibleTokenCount[_from] > 0);
        ownerToBibleTokenCount[_from] = ownerToBibleTokenCount[_from].sub(1);
        delete indexToOwner[_tokenIndex];
    }

    /**
    * @dev Assignes a new NFT to owner.
    * @notice Use and override this function with caution. Wrong usage can have serious consequences.
    * @param _to Address to wich we want to add the NFT.
    * @param _tokenIndex Which NFT we want to add.
    */
    function addNFToken(
        address _to,
        uint256 _tokenIndex
    )
        internal
    {
        require(indexToOwner[_tokenIndex] == address(0));

        indexToOwner[_tokenIndex] = _to;
        ownerToBibleTokenCount[_to] = ownerToBibleTokenCount[_to].add(1);
    }
}
