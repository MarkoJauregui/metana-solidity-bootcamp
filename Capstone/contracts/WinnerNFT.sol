// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title WinnerNFT for Decentralized NFT Lottery System
/// @dev ERC721 token for representing unique rewards for lottery winners
contract WinnerNFT is ERC721, Ownable {
    uint256 private _tokenIds;

    constructor(
        address initialOwner
    ) ERC721("WinnerNFT", "WNFT") Ownable(initialOwner) {}

    /// @notice Mint a WinnerNFT
    /// @dev Only the owner (Lottery contract) can mint WinnerNFTs
    /// @param to The recipient of the NFT
    /// @return tokenId The new token ID
    function mint(address to) external onlyOwner returns (uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        _mint(to, newTokenId);
        return newTokenId;
    }
}
