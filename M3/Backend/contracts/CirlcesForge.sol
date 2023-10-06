// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./CirclesERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

/**
 * @title CirclesForge
 * @author Marko Jauregui
 * @notice Forge contract to interact with CirclesERC1155.sol
 */
contract CirclesForge is IERC1155Receiver {
    // Custom Errors
    error CirclesForge__InsufficientToken0();
    error CirclesForge__InsufficientToken1();
    error CirclesForge__InsufficientToken2();
    error CirclesForge__InvalidTokenId();

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

    // Mapping to track minted token balances for each address
    mapping(address => mapping(uint256 => uint256))
        private s_mintedTokenBalances;

    // Events
    event TokenForged(
        address indexed user,
        uint256 indexed tokenId,
        uint256 indexed amount
    );

    /**
     * @dev Constructor that sets the address of the CirclesERC1155 contract.
     * @param _erc1155Address The address of the CirclesERC1155 contract.
     */
    constructor(address _erc1155Address) {
        s_erc1155Contract = CirclesERC1155(_erc1155Address);
    }

    function mintTokensForContract(uint256 _tokenId, uint256 _amount) external {
        if (_tokenId > TOKEN_ID_2) revert CirclesForge__InvalidTokenId();

        // Mint tokens for the contract address with the specified tokenId
        s_erc1155Contract.mint(address(this), _tokenId, _amount);

        // Update the minted token balance for the contract
        s_mintedTokenBalances[address(this)][_tokenId] += _amount;
    }

    /**
     * @dev Forges Token 3 by burning tokens 0 & 1
     * @param _amount The amount of tokens you burn in exchange for the same amount of forged tokens
     */
    function forgeToken3(uint256 _amount) external {
        // Check for the required tokens in the user's balance
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_0] < 1) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_1] < 1) {
            revert CirclesForge__InsufficientToken1();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(address(this), TOKEN_ID_0, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_1, _amount);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_3, _amount);

        emit TokenForged(msg.sender, TOKEN_ID_3, _amount);
    }

    /**
     * @notice Forges Token 4 by burning Tokens 1 & 2.
     * @param _amount The number of tokens to forge.
     */
    function forgeToken4(uint256 _amount) external {
        // Check for the required tokens in the user's balance
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_1] < _amount) {
            revert CirclesForge__InsufficientToken1();
        }
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_2] < _amount) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(address(this), TOKEN_ID_1, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_2, _amount);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_4, _amount);

        emit TokenForged(msg.sender, TOKEN_ID_4, _amount);
    }

    /**
     * @notice Forges Token 5 by burning tokens 0 and 2.
     * @param _amount The number of tokens to forge.
     */
    function forgeToken5(uint256 _amount) external {
        // Check for the required tokens in the user's balance
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_0] < _amount) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_2] < _amount) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(address(this), TOKEN_ID_0, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_2, _amount);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_5, _amount);

        emit TokenForged(msg.sender, TOKEN_ID_5, _amount);
    }

    /**
     * @notice Forges Token 6 by burning tokens 0, 1, and 2.
     * @param _amount The number of tokens to forge.
     */
    function forgeToken6(uint256 _amount) external {
        // Check for the required tokens in the user's balance
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_0] < _amount) {
            revert CirclesForge__InsufficientToken0();
        }
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_1] < _amount) {
            revert CirclesForge__InsufficientToken1();
        }
        if (s_mintedTokenBalances[address(this)][TOKEN_ID_2] < _amount) {
            revert CirclesForge__InsufficientToken2();
        }

        // Burn the required tokens from the user's balance
        s_erc1155Contract.burn(address(this), TOKEN_ID_0, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_1, _amount);
        s_erc1155Contract.burn(address(this), TOKEN_ID_2, _amount);

        // Mint the new token to the user's balance
        s_erc1155Contract.mint(msg.sender, TOKEN_ID_6, _amount);

        emit TokenForged(msg.sender, TOKEN_ID_6, _amount);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
