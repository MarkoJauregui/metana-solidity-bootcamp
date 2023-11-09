# EVM Puzzle 2 Documentation

## Puzzle 2: Conditional Jump Based on Call Value

### Bytecode Instructions

The bytecode for the second puzzle is as follows:

```
00 34 CALLVALUE
01 38 CODESIZE
02 03 SUB
03 56 JUMP
04 FD REVERT
05 FD REVERT
06 5B JUMPDEST
07 00 STOP
08 FD REVERT
09 FD REVERT
```

### Objective

The objective is to manipulate the `JUMP` at program counter `03` to successfully reach the `JUMPDEST` at `06`.

### Explanation of Opcodes

- `CALLVALUE` (00): Checks how much ether was sent along with the call.
- `CODESIZE` (01): Determines the length of the contract's code.
- `SUB` (02): Subtracts the value below the top of the stack from the top value.
- `JUMP` (03): Moves execution to the opcode located at the address from the top of the stack.
- `REVERT` (04, 05, 08, 09): Reverts the transaction if executed.
- `JUMPDEST` (06): Marks a spot in the code where `JUMP` can land.
- `STOP` (07): Ends the execution.

### Solution Steps

1. **Initialization**: The `CALLVALUE` is placed on the stack (amount of ether sent).
2. **Check Code Length**: `CODESIZE` puts the length of the contract's code on top of the stack.
3. **Calculate Jump Destination**: `SUB` is used to subtract the `CALLVALUE` from `CODESIZE`, with the intention that the result matches the `JUMPDEST` address.
4. **Perform Jump**: `JUMP` reads the result of `SUB` and jumps to that address in the code.
5. **Arrive at Destination**: If the correct amount of ether is sent, `JUMP` takes us to `JUMPDEST`, and the code runs to `STOP`.

### How to Solve

To solve the puzzle:

- The `CODESIZE` is `10` (because we have 10 bytes of code).
- We want to jump to `06`, so we need the `SUB` to result in `6`.
- To get `6` from `SUB`, we need to send `4 wei` with the transaction (because `10 - 4 = 6`).

Therefore, initiate a transaction sending `4 wei` to the contract, which will cause the jump to execute correctly and the program to reach the `STOP` opcode.
