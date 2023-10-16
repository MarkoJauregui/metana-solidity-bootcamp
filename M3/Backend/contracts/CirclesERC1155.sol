// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";

error CirclesERC1155__CooldownNotElapsed();
error CirclesERC1155__InvalidTokenForTrade();
error CirclesERC1155__NotTokenOwnerOrForgeContract();
error CirclesERC1155__InvalidTokenForBurn();
error CirclesERC1155__NotAMinter();
error CirclesERC1155__NotAnAdmin();

/**
 * @title CirclesERC1155
 * @dev A custom ERC1155 token with specific minting, burning, and trading logic.
 */
contract CirclesERC1155 is ERC1155, AccessControlDefaultAdminRules {
    // Constants for token IDs
    uint256 public constant TOKEN_ID_0 = 0;
    uint256 public constant TOKEN_ID_1 = 1;
    uint256 public constant TOKEN_ID_2 = 2;
    uint256 public constant TOKEN_ID_3 = 3;
    uint256 public constant TOKEN_ID_4 = 4;
    uint256 public constant TOKEN_ID_5 = 5;
    uint256 public constant TOKEN_ID_6 = 6;

    /// @notice Role identifier for minters
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Cooldown time for minting tokens 0-2
    uint256 public constant COOLDOWN_TIME = 1 minutes;

    // Storage variables
    address private s_forgingContract;
    mapping(address => uint256) private s_lastMintTimestamp; // Adjusted for global cooldown

    // Events
    event Minted(address indexed user, uint256 indexed tokenId, uint256 amount);
    event Burned(address indexed user, uint256 indexed tokenId, uint256 amount);
    event Traded(
        address indexed user,
        uint256 indexed tokenIdSold,
        uint256 indexed tokenIdBought,
        uint256 amount
    );

    /**
     * @dev Sets the initial state of the contract.
     */
    constructor()
        ERC1155("ipfs://QmdpEYwJircF4qH5imJG4bJT3TH6rNYxzCL2d8B4bG7Uhy/{id}")
        AccessControlDefaultAdminRules(1 days, msg.sender)
    {}

    /**
     * @notice Allows minting of tokens.
     * @param tokenId The ID of the token to mint.
     */
    function mint(address account, uint256 tokenId) public {
        if (tokenId <= TOKEN_ID_2) {
            if (
                block.timestamp - s_lastMintTimestamp[msg.sender] <
                COOLDOWN_TIME
            ) {
                revert CirclesERC1155__CooldownNotElapsed();
            }
            s_lastMintTimestamp[msg.sender] = block.timestamp;
        } else {
            if (!hasRole(MINTER_ROLE, msg.sender)) {
                revert CirclesERC1155__NotAMinter();
            }
        }

        _mint(account, tokenId, 1, ""); // Amount set to 1
        emit Minted(msg.sender, tokenId, 1); // Amount set to 1
    }

    /**
     * @notice Allows users to trade tokens 3-6 for tokens 0-2.
     * @param tokenId The ID of the token to trade.
     * @param desiredToken The ID of the desired token.
     */
    function tradeToken(uint256 tokenId, uint256 desiredToken) public {
        if (!(tokenId >= 3 && tokenId <= 6)) {
            revert CirclesERC1155__InvalidTokenForTrade();
        }
        if (!(desiredToken >= TOKEN_ID_0 && desiredToken <= TOKEN_ID_2)) {
            revert CirclesERC1155__InvalidTokenForTrade();
        }

        _burn(msg.sender, tokenId, 1); // Amount set to 1
        mint(msg.sender, desiredToken); // Amount set to 1 implicitly
        emit Traded(msg.sender, tokenId, desiredToken, 1); // Amount set to 1
    }

    /**
     * @notice Allows burning of tokens.
     * @param tokenId The ID of the token to burn.
     */
    function burn(address account, uint256 tokenId) public {
        if (tokenId < TOKEN_ID_3 || tokenId > TOKEN_ID_6) {
            revert CirclesERC1155__InvalidTokenForBurn();
        }

        _burn(account, tokenId, 1); // Amount set to 1
        emit Burned(account, tokenId, 1); // Amount set to 1
    }

    /**
     * @notice Sets the address of the forging contract.
     * @param _forgingContract The address of the forging contract.
     */
    function setForgingContract(address _forgingContract) public {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert CirclesERC1155__NotAnAdmin();
        }

        if (s_forgingContract != address(0)) {
            revokeRole(MINTER_ROLE, s_forgingContract);
        }

        s_forgingContract = _forgingContract;
        grantRole(MINTER_ROLE, s_forgingContract);
    }

    /**
     * @dev Overrides the supportsInterface function to rectify function selector clashes.
     * @param interfaceId The ID of the interface to check.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155, AccessControlDefaultAdminRules)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Retrieves the last mint timestamp for a user.
     * @param user The address of the user.
     */
    function getLastMintTimestamp(
        address user
    ) external view returns (uint256) {
        return s_lastMintTimestamp[user];
    }
}
