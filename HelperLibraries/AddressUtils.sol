pragma solidity ^0.4.18;

/// @title AddressUtils
/// @dev Utility library of inline functions on addresses
library AddressUtils {

    /// @dev Returns whether the target address is a contract
    /// @param addr address to check
    /// @return whether the target address is a contract
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}
