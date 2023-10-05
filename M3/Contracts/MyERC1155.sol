// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Import Statements
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CirclesERC1155
 * @dev A custom ERC1155 token with specific minting and burning logic.
 */
contract CirclesERC1155 is ERC1155, Ownable {
    // Custom Errors
    error CirclesERC1155__CooldownNotElapsed();
    error CirclesERC1155__InvalidTokenID();
    error CirclesERC1155__NotTokenOwner();

    // Constants for token IDs
    uint256 public constant TOKEN_ID_0 = 0;
    uint256 public constant TOKEN_ID_1 = 1;
    uint256 public constant TOKEN_ID_3 = 3;
    uint256 public constant TOKEN_ID_4 = 4;
    uint256 public constant TOKEN_ID_5 = 5;
    uint256 public constant TOKEN_ID_6 = 6;

    // Cooldown time for minting tokens 0-2
    uint256 public constant COOLDOWN_TIME = 1 minutes;

    /**
     *  @dev Mapping to track the last minting timestamp for each user and each token
     */
    mapping(address => mapping(uint256 => uint256)) private s_lastMintTimestamp;

    // Events
    event Minted(address indexed user, uint256 tokenId, uint256 amount);
    event Burned(address indexed user, uint256 tokenId, uint256 amount);

    //////////////
    // Functions//
    // //////////
    /**
     * @dev Constructor that sets the URI for the ERC1155 token metadata.
     */
    constructor() ERC1155("ipfs://QmdpEYwJircF4qH5imJG4bJT3TH6rNYxzCL2d8B4bG7Uhy/{id}") {}

    /**
     * @dev Allows users to mint tokens with specific logic based on token ID.
     * @param tokenId The ID of the token to mint.
     * @param amount The amount of tokens to mint.
     */
    function mint(uint256 tokenId, uint256 amount) external {
        // Check token ID
        if (tokenId > TOKEN_ID_2 && msg.sender != s_forgingContract) {
            revert CirclesERC1155__InvalidTokenID();
        }

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

    /**
     * @dev Allows users to burn tokens 3-6.
     * @param account The owner of the tokens.
     * @param tokenId The ID of the token to burn.
     * @param amount The amount of tokens to burn.
     */
    function burn(address account, uint256 tokenId, uint256 amount) external {
        // Check if the caller is the owner of the tokens and if the token ID is valid for burning
        // require(msg.sender == account, "You can only burn tokens you own");
        if (msg.sender != account) revert CirclesERC1155__NotTokenOwner();
        if (tokenId < TOKEN_ID_3 || tokenId > TOKEN_ID_6) revert CirclesERC1155__InvalidTokenID();

        _burn(account, tokenId, amount);
        emit Burned(msg.sender, tokenId, amount);
    }

    /**
     * @dev Sets the address of the forging contract.
     * Can only be called by the owner of the contract.
     * @param _forgingContract The address of the forging contract.
     */
    function setForgingContract(address _forgingContract) external onlyOwner {
        s_forgingContract = _forgingContract;
    }
}
