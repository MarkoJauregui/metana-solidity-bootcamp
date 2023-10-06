// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CirclesERC1155
 * @dev A custom ERC1155 token with specific minting and burning logic.
 */
contract CirclesERC1155 is ERC1155, AccessControl {

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

    /// @dev Mapping to track the last minting timestamp for each user and each token
    mapping(address => mapping(uint256 => uint256)) private s_lastMintTimestamp;

    /// @notice Event emitted when tokens are minted
    event Minted(address indexed user, uint256 tokenId, uint256 amount);

    /// @notice Event emitted when tokens are burned
    event Burned(address indexed user, uint256 tokenId, uint256 amount);

    /**
     * @dev Sets the initial state of the contract.
     * @param uri URI for token metadata
     */
    constructor(string memory uri) ERC1155(uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Allows minting of tokens.
     * @dev Checks for appropriate minting role and cooldowns.
     * @param recipient The address receiving the minted tokens.
     * @param tokenId The ID of the token to mint.
     * @param amount The number of tokens to mint.
     */
    function mint(address recipient, uint256 tokenId, uint256 amount) external {
        require(hasRole(MINTER_ROLE, msg.sender), "Not a minter");
        require(tokenId <= TOKEN_ID_6, "Invalid tokenId");

        if (tokenId <= TOKEN_ID_2) {
            require(block.timestamp - s_lastMintTimestamp[msg.sender][tokenId] >= COOLDOWN_TIME, "Cooldown not elapsed");
            s_lastMintTimestamp[msg.sender][tokenId] = block.timestamp;
        }

        _mint(recipient, tokenId, amount, "");
        emit Minted(recipient, tokenId, amount);
    }

    /**
     * @notice Allows burning of tokens.
     * @dev Checks if the caller is the owner of the tokens and if the token ID is valid for burning.
     * @param account The owner of the tokens.
     * @param tokenId The ID of the token to burn.
     * @param amount The number of tokens to burn.
     */
    function burn(address account, uint256 tokenId, uint256 amount) external {
        require(msg.sender == account || msg.sender == s_forgingContract, "Not token owner or forging contract");
        if (tokenId < TOKEN_ID_3 || tokenId > TOKEN_ID_6) {
            require(msg.sender == s_forgingContract, "Invalid tokenId for burning");
        }

        _burn(account, tokenId, amount);
        emit Burned(msg.sender, tokenId, amount);
    }

    /**
     * @notice Sets the address of the forging contract.
     * @dev Only callable by the owner of the contract.
     * @param _forgingContract The address of the forging contract.
     */
    function setForgingContract(address _forgingContract) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not an admin");

        if (s_forgingContract != address(0)) {
            revokeRole(MINTER_ROLE, s_forgingContract);
        }

        s_forgingContract = _forgingContract;
        grantRole(MINTER_ROLE, s_forgingContract);
    }

    /**
     * @dev Overrides the supportsInterface function to rectify function selector clashes.
     * @param interfaceId The ID of the interface to check
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Retrieves the last mint timestamp for a user's specific token.
     * @param user The address of the user.
     * @param tokenId The ID of the token.
     */
    function getLastTimeStamp(address user, uint256 tokenId) external view returns (uint256) {
        return s_lastMintTimestamp[user][tokenId];
    }
}
