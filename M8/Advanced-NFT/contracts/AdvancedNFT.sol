// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

/// @title Advanced NFT Contract
/// @notice This contract implements an NFT with Merkle Tree based airdrop and custom error handling.
contract AdvancedNFT is ERC721 {
    using BitMaps for BitMaps.BitMap;

    /// Custom errors
    error AdvancedNFT__InvalidMerkleProof();
    error AdvancedNFT__TokenAlreadyMinted();

    /// Storage variables
    BitMaps.BitMap private s_minted;
    bytes32 public s_merkleRoot;

    /// @notice Constructor for the Advanced NFT contract.
    /// @param name Name of the NFT collection.
    /// @param symbol Symbol of the NFT collection.
    /// @param _merkleRoot Root of the Merkle Tree used for validating airdrop eligibility.
    constructor(
        string memory name,
        string memory symbol,
        bytes32 _merkleRoot
    ) ERC721(name, symbol) {
        s_merkleRoot = _merkleRoot;
    }

    /// @notice Mints an NFT to the sender if they are eligible according to the Merkle Tree.
    /// @dev Verifies the sender's eligibility using a Merkle proof and ensures each eligible address can only mint once.
    /// @param _merkleProof The Merkle proof that proves the sender's address is in the Merkle Tree.
    /// @param _tokenId The token ID to be minted.
    function mintWithMerkleProof(
        bytes32[] calldata _merkleProof,
        uint256 _tokenId
    ) public {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        if (!MerkleProof.verify(_merkleProof, s_merkleRoot, leaf)) {
            revert AdvancedNFT__InvalidMerkleProof();
        }

        if (s_minted.get(_tokenId)) {
            revert AdvancedNFT__TokenAlreadyMinted();
        }

        s_minted.set(_tokenId);
        _mint(msg.sender, _tokenId);
    }
}
