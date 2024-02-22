// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/Base64.sol";

contract WinnerNFT is ERC721URIStorage, Ownable {
    using Strings for uint256;

    uint256 private _tokenIds;

    constructor(
        address initialOwner
    ) ERC721("WinnerNFT", "WNFT") Ownable(initialOwner) {}

    /// @notice Mint a WinnerNFT with on-chain metadata
    function mint(address to) external onlyOwner returns (uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        _mint(to, newTokenId);
        _setTokenURI(newTokenId, generateTokenURI(newTokenId));
        return newTokenId;
    }

    /// @dev Generates on-chain metadata with an SVG image
    function generateTokenURI(
        uint256 tokenId
    ) private pure returns (string memory) {
        string memory svg = generateSVGImage(tokenId);
        string memory imageURI = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(svg))
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Winner #',
                        tokenId.toString(),
                        '", "description": "A unique NFT for lottery winners!", "image": "',
                        imageURI,
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /// @dev Generates a simple SVG image for the token
    function generateSVGImage(
        uint256 tokenId
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200' fill='none'><rect width='200' height='200' fill='black'/><text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' fill='white' font-size='20'>Winner #",
                    tokenId.toString(),
                    "</text></svg>"
                )
            );
    }
}
