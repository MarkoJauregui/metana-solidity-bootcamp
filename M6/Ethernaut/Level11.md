# Decoding Ethernaut Level 11: Outsmarting the Elevator with Solidity

## Introduction

Embarking on the next phase of my Ethereum journey, I've cracked the puzzle of Level 11 in the OpenZeppelin Ethernaut challenges. This level, themed around an elevator, offers a unique perspective on contract interactions and Solidity's behavior with external calls.

## Challenge Overview

### The Setup

- The `Elevator` contract has a function, `goTo`, which sets its `top` state variable based on the response from a `Building` interface's `isLastFloor` function.
- The goal is to manipulate the `Elevator` into believing it has reached the top floor, even when it hasn't.

### The Vulnerability

- The `Elevator` relies on the external `Building` contract's `isLastFloor` function, which can be manipulated to return inconsistent results within a single transaction.

## The Security Exploit

### Crafting the Attack Contract

- To exploit this, I created an `AttackerBuilding` contract implementing the `Building` interface.
- The contract's `isLastFloor` function was designed to return `false` on its first call and `true` on the second, within the same transaction.

### Executing the Attack

- After deploying the `AttackerBuilding`, I invoked its `attack` function, which in turn called `goTo` on the `Elevator`.
- The `Elevator` received conflicting responses from the `isLastFloor` calls, thus setting its `top` variable to `true`.

## Key Learning Tip

### Understanding External Calls and State Changes

- This challenge highlights the nuances of Solidity's handling of external calls and state changes.
- It underscores the importance of being cautious with external interfaces, as their responses might not always be consistent or reliable.

## Reflections

- Tackling this challenge deepened my understanding of smart contract interactions and potential vulnerabilities. It's a stark reminder of the complex and often unexpected behavior that can arise in decentralized environments.

## Conclusion

- Successfully manipulating the `Elevator` not only marks another milestone in my Ethernaut journey but also reinforces the critical skills needed in secure smart contract development.
