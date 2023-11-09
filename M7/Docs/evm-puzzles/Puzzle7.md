# EVM Puzzle 7 Explanation

To solve this EVM puzzle, we needed to supply calldata that would cause the `CREATE` operation to produce a contract with exactly one byte of non-zero code. Here's how we approached the problem:

## Understanding the Opcodes

First, we reviewed what each opcode in the sequence does:

- `CALLDATASIZE`: Pushes the size of calldata onto the stack.
- `PUSH1 00`: Pushes `0` to the stack, which we use as the memory offset for `CALLDATACOPY`.
- `DUP1`: Duplicates the top value on the stack.
- `CALLDATACOPY`: Copies calldata into memory.
- `CALLDATASIZE`: Pushes the size of calldata onto the stack again.
- `PUSH1 00`: Pushes `0` to the stack again for the new contract's endowment.
- `CREATE`: Takes the top 3 values from the stack and tries to create a new contract.
- `EXTCODESIZE`: Gets the size of the created contract's code.
- `PUSH1 01`: Pushes `1` onto the stack for comparison.
- `EQ`: Compares the size of the contract's code to `1`.
- `JUMPI`: Conditionally jumps to the destination if the sizes are equal.

## Crafting the Calldata

The goal was to make `CREATE` output a contract of exactly one non-zero byte. To do this, we had to ensure the bytecode we provided in calldata would result in such a contract when executed.

The solution `0x60016000F3` is a sequence of bytecode that does the following:

- `0x60` (`PUSH1`): Pushes a byte onto the stack.
- `0x01`: The byte pushed, indicating the size of the code for the `RETURN` operation.
- `0x60` (`PUSH1`): Pushes another byte onto the stack.
- `0x00`: The byte pushed, indicating the memory offset for the `RETURN` operation.
- `0xF3` (`RETURN`): Returns the one byte of code at the specified memory offset.

This sequence effectively tells `CREATE` to form a new contract with the `0x01` byte as its code. The `EXTCODESIZE` of this contract would be `1`, satisfying the condition for `JUMPI` to take us to the `JUMPDEST`.
