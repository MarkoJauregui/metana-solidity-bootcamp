// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract BitWise {
    // Count the number of bits set in data. i.e., data = 7, result = 3
    function countBitSet(uint8 data) public pure returns (uint8 result) {
        for(uint i = 0; i < 8; i += 1) {
            if(((data >> i) & 1) == 1) {
                result += 1;
            }
        }
    }

    // Inline assembly version of countBitSet
    function countBitSetAsm(uint8 data) public pure returns (uint8 result) {
        assembly {
            // Initialize result to 0
            result := 0

            // Loop 8 times, once for each bit
            for { let i := 0 } lt(i, 8) { i := add(i, 1) } {
                // Shift data right by i and check if the least significant bit is 1
                if eq(and(shr(i, data), 1), 1) {
                    // Increment result if the bit is set
                    result := add(result, 1)
                }
            }
        }
    }
}