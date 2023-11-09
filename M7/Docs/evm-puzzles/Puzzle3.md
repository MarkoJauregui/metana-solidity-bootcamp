# EVM Puzzle 3 Documentation

## Puzzle 3: Jump Based on Call Data Size

### Bytecode Instructions

The bytecode for the third puzzle is:

```
00 36 CALLDATASIZE
01 56 JUMP
02 FD REVERT
03 FD REVERT
04 5B JUMPDEST
05 00 STOP
```

### Objective

The goal is to get the `JUMP` at `01` to successfully reach the `JUMPDEST` at `04`.

### Explanation of Opcodes

- `CALLDATASIZE` (00): Retrieves the size of the data sent with the call in bytes.
- `JUMP` (01): Moves the execution to the instruction at the position indicated by the top value of the stack.
- `REVERT` (02, 03): Halts execution and reverts all changes if reached.
- `JUMPDEST` (04): Marks a valid position to jump to.
- `STOP` (05): Ceases execution.

### Solution Steps

1. **Gather Data Size**: The `CALLDATASIZE` will push the size of the incoming call data onto the stack.
2. **Jump to Destination**: The `JUMP` operation will look at the value provided by `CALLDATASIZE` and attempt to jump to that instruction.
3. **Execute `JUMPDEST`**: To reach the `JUMPDEST`, the `CALLDATASIZE` must match the location of the `JUMPDEST` (in this case, `04`).

### How to Solve

To solve this puzzle:

- Send a transaction to the contract with exactly `4 bytes` of data.
- This will set the `CALLDATASIZE` to `4`, which is the address of `JUMPDEST`.

Any 4 bytes of data will work. For example, if we were to send the hex data `0x00000000`, it would count as 4 bytes.
