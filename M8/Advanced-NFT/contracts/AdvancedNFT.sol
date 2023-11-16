// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Advanced NFT Contract
/// @notice Implements an NFT with Merkle Tree based airdrop, commit-reveal for random NFT ID, and custom error handling.
/// @author Marko Jauregui
contract AdvancedNFT is ERC721, Pausable, Multicall, Ownable, ReentrancyGuard {
    using BitMaps for BitMaps.BitMap;

    enum SaleState {
        Presale,
        PublicSale,
        SoldOut
    }
    SaleState public saleState;

    /// Custom errors
    error AdvancedNFT__InvalidMerkleProof();
    error AdvancedNFT__TokenAlreadyMinted();
    error AdvancedNFT__AlreadyRevealed();
    error AdvancedNFT__InvalidReveal();
    error AdvancedNFT__RevealTooEarly();
    error AdvancedNFT__RevealTooLate();

    /// Storage variables
    BitMaps.BitMap private s_minted;
    bytes32 public s_merkleRoot;
    mapping(address => Commit) public s_commits;

    /// Commit struct for the commit-reveal scheme
    struct Commit {
        bytes32 commit;
        uint64 blockNumber;
        bool revealed;
    }

    // Events
    event CommitEvent(
        address indexed sender,
        bytes32 indexed commitHash,
        uint64 blockNumber
    );
    event RevealEvent(
        address indexed sender,
        bytes32 secret,
        bytes32 finalRandom
    );

    modifier inSaleState(SaleState _state) {
        require(
            saleState == _state,
            "AdvancedNFT: Not in the correct sale state"
        );
        _;
    }

    /// @notice Constructor for the Advanced NFT contract.
    /// @param name Name of the NFT collection.
    /// @param symbol Symbol of the NFT collection.
    /// @param _merkleRoot Root of the Merkle Tree used for validating airdrop eligibility.
    constructor(
        string memory name,
        string memory symbol,
        bytes32 _merkleRoot,
        address initialOwner
    ) ERC721(name, symbol) Ownable(initialOwner) {
        s_merkleRoot = _merkleRoot;
        saleState = SaleState.Presale;
    }

    /// @notice Mints an NFT to the sender if they are eligible according to the Merkle Tree.
    /// @dev Verifies the sender's eligibility using a Merkle proof and ensures each eligible address can only mint once.
    /// @param _merkleProof The Merkle proof that proves the sender's address is in the Merkle Tree.
    /// @param _tokenId The token ID to be minted.
    function mintWithMerkleProof(
        bytes32[] calldata _merkleProof,
        uint256 _tokenId
    ) public whenNotPaused inSaleState(SaleState.PublicSale) {
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

    /// @notice Commits a hash for the commit-reveal scheme.
    /// @param _dataHash The hashed data (commitment).
    function commit(bytes32 _dataHash) public {
        Commit storage userCommit = s_commits[msg.sender];
        userCommit.commit = _dataHash;
        userCommit.blockNumber = uint64(block.number);
        userCommit.revealed = false;

        emit CommitEvent(msg.sender, _dataHash, userCommit.blockNumber);
    }

    /// @notice Reveals the secret for a previously made commitment.
    /// @param _secret The original secret data.
    function reveal(bytes32 _secret) public {
        Commit storage userCommit = s_commits[msg.sender];

        if (userCommit.revealed) {
            revert AdvancedNFT__AlreadyRevealed();
        }

        if (userCommit.blockNumber >= block.number) {
            revert AdvancedNFT__RevealTooEarly();
        }

        if (userCommit.blockNumber + 250 < block.number) {
            revert AdvancedNFT__RevealTooLate();
        }

        if (keccak256(abi.encodePacked(_secret)) != userCommit.commit) {
            revert AdvancedNFT__InvalidReveal();
        }

        userCommit.revealed = true;
        // Combine _secret with blockhash for random number generation
        bytes32 finalRandom = keccak256(
            abi.encodePacked(blockhash(userCommit.blockNumber), _secret)
        );
        emit RevealEvent(msg.sender, _secret, finalRandom);
    }

    // Functions to transition sale state
    function startPublicSale() external onlyOwner {
        saleState = SaleState.PublicSale;
    }

    function endSale() external onlyOwner {
        saleState = SaleState.SoldOut;
    }

    /// @notice Withdraws funds to multiple addresses.
    /// @param recipients Array of recipient addresses.
    /// @param amounts Array of amounts to withdraw to each recipient.
    function withdrawFunds(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) public onlyOwner nonReentrant {
        require(
            recipients.length == amounts.length,
            "AdvancedNFT: Mismatched input lengths"
        );

        uint256 totalAmount = 0;
        for (uint i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        require(
            address(this).balance >= totalAmount,
            "AdvancedNFT: Insufficient balance"
        );

        for (uint i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(amounts[i]);
        }
    }

    receive() external payable {}
}
