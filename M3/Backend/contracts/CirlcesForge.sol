// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./CirclesERC1155.sol";

/**
 * @title CirclesForge
 * @notice Forge contract to interact with CirclesERC1155.sol for forging logic.
 */
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
    event TokenForged(address indexed user, uint256 indexed tokenId);

    /**
     * @dev Constructor that sets the address of the CirclesERC1155 contract.
     * @param _erc1155Address The address of the CirclesERC1155 contract.
     */
    constructor(address _erc1155Address) {
        s_erc1155Contract = CirclesERC1155(_erc1155Address);
    }

    /**
     * @notice Forges Token 3 by burning tokens 0 & 1.
     */
    function forgeToken3() external {
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_0) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_1) < 1) {
            revert CirclesForge__InsufficientToken1();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_0);
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_1);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_3);

        emit TokenForged(msg.sender, TOKEN_ID_3);
    }

    /**
     * @notice Forges Token 4 by burning Tokens 1 & 2.
     */
    function forgeToken4() external {
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_1) < 1) {
            revert CirclesForge__InsufficientToken1();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_2) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_1);
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_2);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_4);

        emit TokenForged(msg.sender, TOKEN_ID_4);
    }

    /**
     * @notice Forges Token 5 by burning tokens 0 & 2.
     */
    function forgeToken5() external {
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_0) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_2) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_0);
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_2);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_5);

        emit TokenForged(msg.sender, TOKEN_ID_5);
    }

    /**
     * @notice Forges Token 6 by burning tokens 0, 1, & 2.
     */
    function forgeToken6() external {
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_0) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_1) < 1) {
            revert CirclesForge__InsufficientToken1();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, TOKEN_ID_2) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_0);
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_1);
        s_erc1155Contract.burn(msg.sender, TOKEN_ID_2);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_6);

        emit TokenForged(msg.sender, TOKEN_ID_6);
    }
}
