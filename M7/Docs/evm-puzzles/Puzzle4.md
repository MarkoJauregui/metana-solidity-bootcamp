# EVM Puzzle 4 Documentation

## Puzzle 4: CALLVALUE and XOR for Jumps

### Bytecode Instructions

Here's what we're working with:

```
00 34 CALLVALUE
01 38 CODESIZE
02 18 XOR
03 56 JUMP
04-09 FD REVERT
0A 5B JUMPDEST
0B 00 STOP
```

### Objective

Get from `JUMP` at `03` to safely land on `JUMPDEST` at `0A`.

### What's Happening Here?

- **CALLVALUE**: Checks how much Ether you sent when you started the code.
- **CODESIZE**: It's like asking "How long is this code?" For us, it's `12` because we have 12 pieces.
- **XOR**: Think of it as a special kind of math that compares two numbers and does a magic trick to combine them into a new number.
- **JUMP**: It's our jump rope – it takes us where we want to go, but only if we give it the right number.
- **JUMPDEST**: It's our landing mat, the safe spot to land on.
- **STOP**: Means we're done. Take a breather!

### Figuring It Out

1. **Start with CALLVALUE**: How much Ether did we put in?
2. **Get CODESIZE**: It tells us the code is 12 steps long.
3. **XOR Time**: It's like a secret handshake between CALLVALUE and CODESIZE to give us a new number.
4. **Make the Jump**: Use that new number from XOR to jump to our landing mat (JUMPDEST).

### Making It Work

So, we need our secret handshake (XOR) to give us the number `10` because that's where our landing mat (JUMPDEST) is.

If we think of CODESIZE like it's the number `12`, and we know our landing mat is at `10`, what number should we start with (CALLVALUE) to get `10` after the secret handshake?

After a bit of thinking and playing with numbers, turns out if we start with `6`, our secret handshake with `12` gives us exactly `10`. That's our magic number!

### To Solve

- Send the contract `6` Ether (but like, not real Ether – we're practicing).
- That will make our XOR handshake work just right and lead us to `JUMPDEST`.
