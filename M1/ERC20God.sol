// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import statements
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20God is ERC20 {
    // Custom Errrors

    error ERC20God__NotGodAddress();
    error ERC20God__InsufficientFromBalance();
  
    address private god;

    modifier onlyGod(){
        //require(msg.sender == god, "Only God can Invoke this");
        if(msg.sender != god) revert ERC20God__NotGodAddress();
        _;
    }

    constructor(string memory name, string memory symbol, address godAddress) ERC20(name,symbol){
        god = godAddress;
    }

     // Allow god to mint tokens to any address
    function mintTokensToAddress(address recipient, uint256 amount) public  onlyGod {
        _mint(recipient, amount);
    }

     // Allow god to change the balance of any address
    function changeBalanceAtAddress(address target, uint256 newBalance) public onlyGod {
        uint256 currentBalance = balanceOf(target);
        if(newBalance > currentBalance){
            uint256 mintAmount = newBalance - currentBalance;
            _mint(target, mintAmount);
        } else {
            uint256 burnAmount = currentBalance - newBalance;
            _burn(target, burnAmount);
        }
    }
    // Allow god to forcefully transfer tokens from one address to another by burning and reminting.
    function authorativeTransferFrom(address from, address to, uint256 amount)  public onlyGod {
      if(balanceOf(from) <= amount) revert ERC20God__InsufficientFromBalance();

      // Now you burn the amount from the "from" address and mint it to the "to" address.
      _burn(from, amount);
      _mint(to, amount);
    }
}
