// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title TicketNFT for Decentralized NFT Lottery System
/// @dev ERC1155 token for representing lottery tickets
contract TicketNFT is ERC1155, Ownable {
    constructor(
        address initialOwner
    ) ERC1155("TicketNFT URI") Ownable(initialOwner) {}

    /// @notice Mint new tickets
    /// @dev Only the owner (Lottery contract) can mint tickets
    /// @param account The account to receive the tickets
    /// @param id The ticket identifier
    /// @param amount The number of tickets to mint
    /// @param data Additional data
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyOwner {
        _mint(account, id, amount, data);
    }

    /// @notice Burn tickets
    /// @dev Only the owner (Lottery contract) can burn tickets
    /// @param account The account whose tickets are burnt
    /// @param id The ticket identifier
    /// @param amount The number of tickets to burn
    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) external onlyOwner {
        _burn(account, id, amount);
    }
}
