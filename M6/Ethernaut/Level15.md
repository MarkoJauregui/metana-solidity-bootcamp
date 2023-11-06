## Overcoming the NaughtCoin Challenge: Ethernaut Level 17

### Introduction

In the adventurous journey through the Ethernaut game, Level 17 presents a unique challenge with NaughtCoin. This ERC20 token has a catch: it's locked for a 10-year period. The objective is to transfer all tokens to another address, bypassing the lock.

### Challenge Overview

- **The Setup**: NaughtCoin is an ERC20 token with a 10-year lockout period for transfers. However, other ERC20 functions are not restricted.
- **Goal**: Reduce the player's token balance to 0, by transferring the tokens to another address.

### Approach and Solution

1. **Understanding ERC20 Functions**:

   - ERC20 tokens have standard functions like `transfer`, `approve`, and `transferFrom`.
   - The `transfer` function is locked, but `approve` and `transferFrom` are available.

2. **Steps Executed**:

   - **Check Current Balance**: Used `contract.balanceOf(player)` to confirm the total token balance.
   - **Approve Another Account**: Executed `contract.approve(anotherAccount, totalBalance)`.
   - **Transfer Tokens**: Called `contract.transferFrom(player, recipient, totalBalance)` from the approved account.

3. **Dealing with Gas Issues**:

   - Encountered a gas error (`insufficient allowance`), indicating the need to adjust the `maxFeePerGas`.
   - Ensured that the `approve` function was successfully executed and confirmed on the blockchain before attempting `transferFrom`.

4. **Successful Transfer**:
   - The tokens were successfully transferred to another account, reducing the player's balance to 0.

### Key Learnings

- **ERC20 Flexibility**: Even with `transfer` restrictions, other functions like `approve` and `transferFrom` can be used creatively to move tokens.
- **Gas Management**: Understanding gas fees and their adjustment is crucial in executing transactions.
- **Blockchain Confirmation**: Ensuring transactions are confirmed on the blockchain before proceeding with dependent transactions.

### Conclusion

This level was a practical lesson in ERC20 token mechanics and smart contract interaction nuances, reinforcing the importance of understanding contract functions and Ethereum transaction dynamics.
