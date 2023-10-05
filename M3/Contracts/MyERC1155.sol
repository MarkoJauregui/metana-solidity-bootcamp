// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CirclesERC1155 is ERC1155, Ownable {
    // Custom Errors
    error CirclesERC1155_CooldownNotElapsed();
    error CirclesERC1155_InvalidTokenID();

    // Constants for token IDs
    uint256 public constant TOKEN_ID_0 = 0;
    uint256 public constant TOKEN_ID_1 = 1;
    uint256 public constant TOKEN_ID_2 = 2;
    uint256 public constant TOKEN_ID_3 = 3;
    uint256 public constant TOKEN_ID_4 = 4;
    uint256 public constant TOKEN_ID_5 = 5;
    uint256 public constant TOKEN_ID_6 = 6;

    // Cooldown time for minting tokens 0-2
    uint256 public constant COOLDOWN_TIME = 1 minutes;

    // Storage: Mapping to track the last minting timestamp for each user and each token
    mapping(address => mapping(uint256 => uint256)) private s_lastMintTimestamp;

    constructor() ERC1155("https://myapi.com/api/token/{id}.json") {}

    function mint(uint256 tokenId, uint256 amount) external {
        // Check token ID
        if (tokenId > TOKEN_ID_2) revert CirclesERC1155_InvalidTokenID();

        // Check if cooldown time has elapsed
        if (block.timestamp - s_lastMintTimestamp[msg.sender][tokenId] < COOLDOWN_TIME) {
            revert CirclesERC1155_CooldownNotElapsed();
        }

        // Update the last minting timestamp
        s_lastMintTimestamp[msg.sender][tokenId] = block.timestamp;

        // Mint the token
        _mint(msg.sender, tokenId, amount, "");
    }

    // ... rest of the functions
}
