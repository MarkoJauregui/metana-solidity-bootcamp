# EVM Puzzle Documentation

## Puzzle 1: Jump to Destination

### Bytecode Instructions

The following bytecode instructions are provided for the puzzle:

```
00 34 CALLVALUE
01 56 JUMP
02 FD REVERT
03 FD REVERT
04 FD REVERT
05 FD REVERT
06 FD REVERT
07 FD REVERT
08 5B JUMPDEST
09 00 STOP
```

### Objective

To complete the puzzle, the `JUMP` instruction at program counter `01` must successfully jump to `JUMPDEST` at `08`.

### Solution Approach

- **Step 1:** Send a transaction to the smart contract with `8 wei` as `msg.value`.
- **Step 2:** The `CALLVALUE` opcode at `00` will push `8` onto the stack since `msg.value` is `8 wei`.
- **Step 3:** The `JUMP` opcode at `01` will then pop `8` from the stack and jump to the instruction at the `08` program counter because `JUMP` is a conditional jump that uses the top of the stack as the destination address.
- **Step 4:** The execution will continue from `08` with `JUMPDEST` and subsequently encounter `STOP` at `09`, halting the execution successfully.

### Gas Estimation

- `CALLVALUE`: Consumes base gas.
- `JUMP`: Consumes higher gas as it's a control operation.
- `JUMPDEST`: Minimal gas since it's a marker.
- `STOP`: Consumes base gas.

Each opcode consumes a specific amount of gas, and the exact values can be found in the Ethereum Yellow Paper or the respective EIPs for opcode gas costs.

### Notes

- The `REVERT` opcodes are not executed in the successful path since the jump bypasses them.
- The `msg.value` must precisely match the desired jump location in the bytecode.
