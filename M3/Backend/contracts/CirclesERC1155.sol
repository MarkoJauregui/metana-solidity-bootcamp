// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Import Statements
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title CirclesERC1155
/// @dev A custom ERC1155 token with specific minting and burning logic.
contract CirclesERC1155 is ERC1155, AccessControl {
    // Custom Errors
    error CirclesERC1155__CooldownNotElapsed();
    error CirclesERC1155__InvalidTokenID();
    error CirclesERC1155__NotTokenOwner();
    error CirclesERC1155__NotMinter();
    error CirclesERC1155__NotAdmin();

    /// @notice Role identifier for minters
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Constants for token IDs
    uint256 public constant TOKEN_ID_0 = 0;
    uint256 public constant TOKEN_ID_1 = 1;
    uint256 public constant TOKEN_ID_2 = 2;
    uint256 public constant TOKEN_ID_3 = 3;
    uint256 public constant TOKEN_ID_4 = 4;
    uint256 public constant TOKEN_ID_5 = 5;
    uint256 public constant TOKEN_ID_6 = 6;

    /// @notice Cooldown time for minting tokens 0-2
    uint256 public constant COOLDOWN_TIME = 1 minutes;

    // Storage variables
    address private s_forgingContract;

    /// @dev Mapping to track the last minting timestamp for each user and each token
    mapping(address => mapping(uint256 => uint256)) private s_lastMintTimestamp;

    /// @notice Event emitted when tokens are minted
    event Minted(address indexed user, uint256 tokenId, uint256 amount);

    /// @notice Event emitted when tokens are burned
    event Burned(address indexed user, uint256 tokenId, uint256 amount);

    /// @dev Sets the initial state of the contract.
    constructor() ERC1155("ipfs://QmdpEYwJircF4qH5imJG4bJT3TH6rNYxzCL2d8B4bG7Uhy/{id}") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Allows minting of tokens.
    /// @dev Checks for appropriate minting role and cooldowns.
    /// @param tokenId The ID of the token to mint.
    /// @param amount The number of tokens to mint.
    function mint(uint256 tokenId, uint256 amount) external {
        if (!hasRole(MINTER_ROLE, msg.sender)) revert CirclesERC1155__NotMinter();

        // If token ID is 0-2, check for cooldown
        if (tokenId <= TOKEN_ID_2) {
            if (block.timestamp - s_lastMintTimestamp[msg.sender][tokenId] < COOLDOWN_TIME) {
                revert CirclesERC1155__CooldownNotElapsed();
            }
            s_lastMintTimestamp[msg.sender][tokenId] = block.timestamp;
        }

        // Mint the token
        _mint(msg.sender, tokenId, amount, "");
        emit Minted(msg.sender, tokenId, amount);
    }

    /// @notice Allows burning of tokens.
    /// @dev Checks if the caller is the owner of the tokens and if the token ID is valid for burning.
    /// @param account The owner of the tokens.
    /// @param tokenId The ID of the token to burn.
    /// @param amount The number of tokens to burn.
    function burn(address account, uint256 tokenId, uint256 amount) external {
        if (msg.sender != account) revert CirclesERC1155__NotTokenOwner();
        if (tokenId < TOKEN_ID_3 || tokenId > TOKEN_ID_6) revert CirclesERC1155__InvalidTokenID();

        _burn(account, tokenId, amount);
        emit Burned(msg.sender, tokenId, amount);
    }

    /// @notice Sets the address of the forging contract.
    /// @dev Only callable by the owner of the contract.
    /// @param _forgingContract The address of the forging contract.
    function setForgingContract(address _forgingContract) external {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert CirclesERC1155__NotAdmin();
        }

        if (s_forgingContract != address(0)) {
            // If there was a previous forging contract, we revoke its MINTER_ROLE.
            revokeRole(MINTER_ROLE, s_forgingContract);
        }

        s_forgingContract = _forgingContract;

        // Grant the new forging contract the MINTER_ROLE.
        grantRole(MINTER_ROLE, s_forgingContract);
    }

    /// @dev Overrides the supportsInterface function to rectify function selector clashes.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // The following functions simply return the constant token IDs. They might be useful for external integrations.
    function getTokenId0() external pure returns (uint256) {
        return TOKEN_ID_0;
    }

    function getTokenId1() external pure returns (uint256) {
        return TOKEN_ID_1;
    }

    function getTokenId2() external pure returns (uint256) {
        return TOKEN_ID_2;
    }

    function getTokenId3() external pure returns (uint256) {
        return TOKEN_ID_3;
    }

    function getTokenId4() external pure returns (uint256) {
        return TOKEN_ID_4;
    }

    function getTokenId5() external pure returns (uint256) {
        return TOKEN_ID_5;
    }

    function getTokenId6() external pure returns (uint256) {
        return TOKEN_ID_6;
    }
}
