// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract String {
    function charAt(
        string memory str,
        uint256 index
    ) public pure returns (bytes2) {
        bytes memory bytesStr = bytes(str);
        bytes2 result;
        assembly {
            let length := mload(bytesStr)
            if iszero(lt(index, length)) {
                result := 0x0000
            }
            if lt(index, length) {
                let char := byte(0, mload(add(add(bytesStr, 0x20), index)))
                result := shl(248, char)
            }
        }
        return result;
    }
}
