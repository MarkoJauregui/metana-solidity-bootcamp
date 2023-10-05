// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Import Statements
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CirclesERC1155
 * @dev A custom ERC1155 token with specific minting and burning logic.
 */
contract CirclesERC1155 is ERC1155, AccessControl {
    // Custom Errors
    error CirclesERC1155__CooldownNotElapsed();
    error CirclesERC1155__InvalidTokenID();
    error CirclesERC1155__NotTokenOwner();
    error CirclesERC1155__NotMinter();
    error CirclesERC1155__NotAdmin();

    // Define the MINTER_ROLE identifier
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Constants for token IDs
    uint256 public constant TOKEN_ID_0 = 0;
    uint256 public constant TOKEN_ID_1 = 1;
    uint256 public constant TOKEN_ID_2 = 2;
    uint256 public constant TOKEN_ID_3 = 3;
    uint256 public constant TOKEN_ID_4 = 4;
    uint256 public constant TOKEN_ID_5 = 5;
    uint256 public constant TOKEN_ID_6 = 6;

    // Cooldown time for minting tokens 0-2
    uint256 public constant COOLDOWN_TIME = 1 minutes;

    // Storage variables
    address private s_forgingContract;
    mapping(address => mapping(uint256 => uint256)) private s_lastMintTimestamp; // Mapping to track the last minting timestamp for each user and each token

    // Events
    event Minted(address indexed user, uint256 tokenId, uint256 amount);
    event Burned(address indexed user, uint256 tokenId, uint256 amount);

    constructor() ERC1155("ipfs://QmdpEYwJircF4qH5imJG4bJT3TH6rNYxzCL2d8B4bG7Uhy/{id}") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

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

    function burn(address account, uint256 tokenId, uint256 amount) external {
        if (msg.sender != account) revert CirclesERC1155__NotTokenOwner();
        if (tokenId < TOKEN_ID_3 || tokenId > TOKEN_ID_6) revert CirclesERC1155__InvalidTokenID();

        _burn(account, tokenId, amount);
        emit Burned(msg.sender, tokenId, amount);
    }

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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

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
