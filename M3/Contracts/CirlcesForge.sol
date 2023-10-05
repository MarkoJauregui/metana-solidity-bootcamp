// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./CirclesERC1155.sol";

contract CirclesForge {
    // Custom Errors
    error CirclesForge__InsufficientToken0();
    error CirclesForge__InsufficientToken1();
    error CirclesForge__InsufficientToken2();

    // Storage: Instance of the ERC1155 contract
    CirclesERC1155 private s_erc1155Contract;

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
        // Check caller has enough token 0 & 1 to burn
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_0) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_1) < 1) {
            revert CirclesForge__InsufficientToken0();
        }

        // Burn tokens 0 & 1 from caller account
        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_0, 1);
        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_1, 1);

        // Mint Token 3 to caller account
        s_erc1155Contract.mint(msg.sender, CirclesERC1155.TOKEN_ID_3, 1);
    }

    /**
     * @dev Forges Token 4 by burning Tokens 1 & 2
     */
    function forgeToken4() external {
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_1) < 1) {
            revert CirclesForge__InsufficientToken1();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_2) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_1, 1);
        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_2, 1);

        s_erc1155Contract.mint(msg.sender, CirclesERC1155.TOKEN_ID_4, 1);
    }

    /**
     * @dev Forges Token 5 by burning tokens 0 and 2.
     */
    function forgeToken5() external {
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_0) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_2) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_0, 1);
        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_2, 1);

        s_erc1155Contract.mint(msg.sender, CirclesERC1155.TOKEN_ID_5, 1);
    }

    /**
     * @dev Forges Token 6 by burning tokens 0, 1, and 2.
     */
    function forgeToken6() external {
        // Ensure the caller has enough of tokens 0, 1, and 2 to burn
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_0) < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_1) < 1) {
            revert CirclesForge__InsufficientToken1();
        }
        if (s_erc1155Contract.balanceOf(msg.sender, CirclesERC1155.TOKEN_ID_2) < 1) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn tokens 0, 1, and 2 from caller's account
        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_0, 1);
        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_1, 1);
        s_erc1155Contract.burn(msg.sender, CirclesERC1155.TOKEN_ID_2, 1);

        // Mint Token 6 to caller's account
        s_erc1155Contract.mint(msg.sender, CirclesERC1155.TOKEN_ID_6, 1);
    }
}
