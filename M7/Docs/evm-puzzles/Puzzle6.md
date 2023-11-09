# EVM Puzzle 6 Explanation

## Puzzle 6: Using CALLDATALOAD for JUMP

### Understanding the Bytecode Instructions

The EVM bytecode provided presents these operations:

```
00 6000 PUSH1 00 // Pushes the byte 00 onto the stack.
02 35 CALLDATALOAD // Loads 32 bytes of calldata onto the stack, starting at the offset given by the top of the stack.
03 56 JUMP // Jumps to the position in code specified by the top of the stack.
04-09 FD REVERT // Opcode for reverting the transaction (unused in the solution).
0A 5B JUMPDEST // The destination of the jump, marked at position 0A.
0B 00 STOP // Stops the execution.
```

### The Objective

To complete this puzzle, we need to make the program counter jump to the `JUMPDEST` opcode at position `0A`.

### The Approach

1. **PUSH1 00**: This command places '00' as the starting point for `CALLDATALOAD` to begin reading data.
2. **CALLDATALOAD**: Retrieves the first 32 bytes of calldata based on the starting point provided by `PUSH1`.
3. **JUMP**: Uses the value provided by `CALLDATALOAD` to jump to the corresponding `JUMPDEST`.

### The Solution

- We need to send calldata with the first 32 bytes structured so that `CALLDATALOAD` will place the value `0A` on the stack. In Ethereum, numbers are stored in big-endian format.
- The correct calldata will be `0x000000000000000000000000000000000000000000000000000000000000000A`, ensuring the stack's top value is `0A` when the `JUMP` instruction is called.
