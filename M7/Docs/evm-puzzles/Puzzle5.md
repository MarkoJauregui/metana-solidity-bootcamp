# EVM Puzzle 5 Documentation

## Puzzle 5: Duplication, Multiplication, and Equality Check

### Bytecode Instructions

This time, our puzzle looks like this:

```
00 34 CALLVALUE
01 80 DUP1
02 02 MUL
03 610100 PUSH2 0100
06 14 EQ
07 600C PUSH1 0C
09 57 JUMPI
0A-0B FD REVERT
0C 5B JUMPDEST
0D 00 STOP
0E-0F FD REVERT
```

### Objective

Figure out the correct `CALLVALUE` that allows us to jump to `JUMPDEST` at `0C`.

### The Game Plan

Here's the rundown of what each opcode does in our puzzle:

- **CALLVALUE**: Gets us started with how much Ether we're sending (we'll call this amount `x`).
- **DUP1**: Clones our `x`, so we now have two of them.
- **MUL**: Multiplies our two `x` values (so it's `x` times `x`).
- **PUSH2 0100**: This is like saying, "We want the answer to be `256`," because `0100` is `256` in "computer numbers" (hexadecimal).
- **EQ**: Checks if our multiplication answer equals `256`.
- **PUSH1 0C**: Adds `12` to our stack, setting up where we want to jump.
- **JUMPI**: The big leap! It jumps to the code at `12` if `EQ` said our multiplication was right.

### Cracking the Code

1. **Starting with CALLVALUE**: We want to send some Ether (not for real, just pretend).
2. **DUP1** makes a duplicate of the Ether amount.
3. **MUL** then multiplies the original and duplicate Ether amounts.
4. We want the result of **MUL** to match `256` because that's what we push onto the stack next.
5. **EQ** will give us a thumbs up (the number `1`) if we did it right.
6. If **EQ** is happy, **JUMPI** will bounce us over to `JUMPDEST` at `0C`.

### The Magic Number

- We need to send an Ether amount that, when squared, equals `256`.
- That amount is `16` because `16` times `16` equals `256`.
