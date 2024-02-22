// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./utils/Base64.sol";

contract TicketNFT is ERC1155, Ownable {
    using Strings for uint256;

    string private constant BASE_IMAGE_URI =
        "ipfs://QmNczNyaNT9ARGSdp2eRQeQjNjqWsPTGUiGH8GpToQrqDX";
    // Mapping from token ID to custom token URI (if needed for future use)
    mapping(uint256 => string) private _tokenURIs;

    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {}

    /// @notice Mint new tickets
    /// @dev Only the owner (Lottery contract) can mint tickets
    /// @param account The account to receive the tickets
    /// @param id The ticket identifier (lottery ID)
    /// @param amount The number of tickets to mint
    /// @param data Additional data
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyOwner {
        _mint(account, id, amount, data);
        // Optionally set a unique URI per token ID if needed
        // _setTokenURI(id, generateTokenURI(id));
    }

    /// @notice Generates a token URI for a given token ID
    /// @dev This includes the lottery ID in the metadata
    /// @param id The token ID
    /// @return The full token URI with metadata
    function uri(uint256 id) public view override returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Lottery Ticket #',
                        id.toString(),
                        '", "description": "A ticket for the Lottery #',
                        id.toString(),
                        '. Participate to win!", "image": "',
                        BASE_IMAGE_URI,
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
