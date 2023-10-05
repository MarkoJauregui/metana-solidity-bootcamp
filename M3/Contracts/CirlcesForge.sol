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
        s_erc1155Contract.mint(msg.sender, CirclesERC1155)
    }
}
