// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Imports
//---------------------------
import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MetanaStableCoin
 * @author Marko Jauregui
 * @notice This contract is governed by the MSCEngine contract.This is just the ERC20 implementation.
 */
contract MetanaStableCoin is ERC20Burnable, Ownable {
    // Custom Errors
    error MetanaStableCoin__MustBeMoreThanZero();
    error MetanaStableCoin__BurnAmountExceedsBalance();
    error MetanaStableCoin__ZeroAddress();

    // Functions
    constructor() ERC20("MetanaStableCoin", "MSC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) revert MetanaStableCoin__MustBeMoreThanZero();
        if (balance < _amount) {
            revert MetanaStableCoin__BurnAmountExceedsBalance();
        }

        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) revert MetanaStableCoin__ZeroAddress();
        if (_amount <= 0) revert MetanaStableCoin__MustBeMoreThanZero();

        _mint(_to, _amount);
        return true;
    }
}
