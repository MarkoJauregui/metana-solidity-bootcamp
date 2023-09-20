// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20God is ERC20 {
    address private god;

    modifier onlyGod(){
        require(msg.sender == god, "Only God can Invoke this");
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
    
}