# EVM Puzzle Solution Explanation

## Puzzle Overview

In this puzzle, our goal is to manipulate the Ethereum Virtual Machine (EVM) into executing a specific sequence of opcodes that ultimately leads to a successful `JUMPI` (conditional jump) to a `JUMPDEST` (the destination of the jump).

## Objective

- Create a contract using `CREATE` with specific bytecode.
- Ensure that a `CALL` to this newly created contract returns `0`.
- This will make an `EQ` comparison true since it compares the result of the `CALL` (which should be `0`) with `0`.
- Then the `JUMPI` instruction will jump to the specified `JUMPDEST` if the comparison is true.

## Crafting the Payload

To make this happen, we need to send calldata that will create a contract that always reverts. Why? Because a revert means the `CALL` will fail, and by EVM conventions, a failed `CALL` returns `0`.

Here are the steps we used to craft the calldata:

```
1. [Add `PUSH1` opcode and the byte to push] - This pushes the `REVERT` opcode (`FD`) onto the stack.
2. [Add `PUSH1` opcode and the byte to push] - This pushes the memory location `00` onto the stack.
3. [Add `MSTORE8` opcode] - This stores the top byte on the stack (`FD`) into memory at location `00`.
4. [Add `PUSH1` opcode and the byte to push] - This pushes `01` onto the stack, which is the size of the data we will return.
5. [Add `PUSH1` opcode and the byte to push] - This pushes `00` onto the stack, indicating the offset for the `RETURN` operation.
6. [Add `RETURN` opcode] - This returns the data starting at offset `00` and continuing for `01` bytes (just the `REVERT` opcode).
```

The resulting calldata is `0x60FD60005360016000F3`. When this data is used in the `CREATE` operation, it deploys a new contract containing just the `REVERT` opcode.
