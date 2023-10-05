// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./CirclesERC1155.sol";

contract CirclesForge {
    // Storage: Instance of the ERC1155 contract
    CirclesERC1155 private s_erc1155Contract;

    /**
     * @dev Constructor that sets the address of the CirclesERC1155 contract.
     * @param _erc1155Address The address of the CirclesERC1155 contract.
     */
    constructor(address _erc1155Address) {
        s_erc1155Contract = CirclesERC1155(_erc1155Address);
    }

    // ... Forging functions to come ...
}
