// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./CirclesERC1155.sol";

contract CirclesForge {
    // Custom Errors
    error CirclesForge__InsufficientToken0();
    error CirclesForge__InsufficientToken1();
    error CirclesForge__InsufficientToken2();

    // Constants for token IDs
    uint256 public constant TOKEN_ID_0 = 0;
    uint256 public constant TOKEN_ID_1 = 1;
    uint256 public constant TOKEN_ID_2 = 2;
    uint256 public constant TOKEN_ID_3 = 3;
    uint256 public constant TOKEN_ID_4 = 4;
    uint256 public constant TOKEN_ID_5 = 5;
    uint256 public constant TOKEN_ID_6 = 6;

    // Storage: Instance of the ERC1155 contract
    CirclesERC1155 private s_erc1155Contract;

    // Events
    event TokenForged(address indexed user, uint256 tokenId);

    /**
     * @dev Constructor that sets the address of the CirclesERC1155 contract.
     * @param _erc1155Address The address of the CirclesERC1155 contract.
     */
    constructor(address _erc1155Address) {
        s_erc1155Contract = CirclesERC1155(_erc1155Address);
    }

    /**
     * @dev Forges Token 3 by burning tokens 0 & 1
     */
    function forgeToken3() external {
        // Check for the required tokens in the user's balance
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId0()) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId1()) < 1) {
            revert CirclesForge__InsufficientToken1();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId0(), 1);
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId1(), 1);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(s_erc1155Contract.getTokenId3(), 1);

        emit TokenForged(msg.sender, s_erc1155Contract.getTokenId3());
    }

    /**
     * @dev Forges Token 4 by burning Tokens 1 & 2
     */
    function forgeToken4() external {
        // Check for the required tokens in the user's balance
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId1()) < 1) {
            revert CirclesForge__InsufficientToken1();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId2()) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId1(), 1);
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId2(), 1);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(s_erc1155Contract.getTokenId4(), 1);

        emit TokenForged(msg.sender, s_erc1155Contract.getTokenId4());
    }

    /**
     * @dev Forges Token 5 by burning tokens 0 and 2.
     */
    function forgeToken5() external {
        // Check for the required tokens in the user's balance
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId0()) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId2()) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId0(), 1);
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId2(), 1);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(s_erc1155Contract.getTokenId5(), 1);

        emit TokenForged(msg.sender, s_erc1155Contract.getTokenId5());
    }

    /**
     * @dev Forges Token 6 by burning tokens 0, 1, and 2.
     */
    function forgeToken6() external {
        // Check for the required tokens in the user's balance
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId0()) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId1()) < 1) {
            revert CirclesForge__InsufficientToken1();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, s_erc1155Contract.getTokenId2()) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId0(), 1);
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId1(), 1);
        s_erc1155Contract.burn(msg.sender, s_erc1155Contract.getTokenId2(), 1);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(s_erc1155Contract.getTokenId6(), 1);

        emit TokenForged(msg.sender, s_erc1155Contract.getTokenId6());
    }
}
