// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./CirclesERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

/**
 * @title CirclesForge
 * @dev Contract to handle the forging logic for the CirclesERC1155 tokens.
 */
contract CirclesForge is IERC1155Receiver {

    // Constants for token IDs
    uint256 public constant TOKEN_ID_0 = 0;
    uint256 public constant TOKEN_ID_1 = 1;
    uint256 public constant TOKEN_ID_2 = 2;
    uint256 public constant TOKEN_ID_3 = 3;
    uint256 public constant TOKEN_ID_4 = 4;
    uint256 public constant TOKEN_ID_5 = 5;
    uint256 public constant TOKEN_ID_6 = 6;

    // Instance of the ERC1155 contract
    CirclesERC1155 private s_erc1155Contract;

    /**
     * @dev Constructor that sets the address of the CirclesERC1155 contract.
     * @param _erc1155Address The address of the CirclesERC1155 contract.
     */
    constructor(address _erc1155Address) {
        s_erc1155Contract = CirclesERC1155(_erc1155Address);
    }

    /**
     * @notice Allows the forging contract to mint tokens.
     * @dev Only tokens 0-2 can be minted using this function.
     * @param _tokenId The ID of the token to mint.
     * @param _amount The number of tokens to mint.
     */
    function mintTokensForContract(uint256 _tokenId, uint256 _amount) external {
        require(_tokenId <= TOKEN_ID_2, "Invalid tokenId for minting");

        s_erc1155Contract.mint(address(this), _tokenId, _amount);
    }

    /**
     * @notice Forges Token 3 by burning Tokens 0 & 1.
     * @param _amount The number of tokens to forge.
     */
    function forgeToken3(uint256 _amount) external {
        s_erc1155Contract.burn(address(this), TOKEN_ID_0, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_1, _amount);
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_3, _amount);

        emit TokenForged(msg.sender, TOKEN_ID_3);
    }

    /**
     * @notice Forges Token 4 by burning Tokens 1 & 2.
     * @param _amount The number of tokens to forge.
     */
    function forgeToken4(uint256 _amount) external {
        s_erc1155Contract.burn(address(this), TOKEN_ID_1, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_2, _amount);
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_4, _amount);

        emit TokenForged(msg.sender, TOKEN_ID_4);
    }

    /**
     * @notice Forges Token 5 by burning Tokens 0 & 2.
     * @param _amount The number of tokens to forge.
     */
    function forgeToken5(uint256 _amount) external {
        s_erc1155Contract.burn(address(this), TOKEN_ID_0, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_2, _amount);
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_5, _amount);

        emit TokenForged(msg.sender, TOKEN_ID_5);
    }

    /**
     * @notice Forges Token 6 by burning Tokens 0, 1 & 2.
     * @param _amount The number of tokens to forge.
     */
    function forgeToken6(uint256 _amount) external {
        s_erc1155Contract.burn(address(this), TOKEN_ID_0, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_1, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_2, _amount);
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_6, _amount);

        emit TokenForged(msg.sender, TOKEN_ID_6);
    }

    /**
     * @dev Ensures that the contract conforms to the ERC1155Receiver interface.
     * @param interfaceId The ID of the interface to check.
     */
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    /**
     * @dev Handles the receipt of single ERC1155 tokens.
     */
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns(bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     * @dev Handles the receipt of multiple ERC1155 tokens.
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns(bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev Event emitted when tokens are forged.
     * @param user The address of the user who forged the token.
     * @param tokenId The ID of the forged token.
     */
    event TokenForged(address indexed user, uint256 tokenId);
}
