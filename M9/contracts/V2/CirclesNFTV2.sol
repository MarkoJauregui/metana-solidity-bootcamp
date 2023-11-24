// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title CirclesNFT Contract with God Mode
/// @notice This contract allows minting of NFTs and includes a 'god mode' for forced transfers.
/// @dev Extends ERC721 Upgradeable Token Standard and Ownable for access control.
/// @author Marko Jauregui
contract CirclesNFTV2 is Initializable, ERC721Upgradeable, OwnableUpgradeable {
    error CirclesNFT__MaxSupplyReached();
    error CirclesNFT__WrongMintingPrice();
    error CirclesNFT__TokenDoesNotExist();
    error CirclesNFT__Unauthorized();

    uint256 public s_tokenSupply;
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant PRICE = 0.01 ether;
    address public stakingContract;

    function initialize() public initializer {
        __ERC721_init("Circles NFT", "o");
        __Ownable_init();
        s_tokenSupply = 0;
    }

    /// @notice Mints a new NFT if the max supply hasn't been reached and the correct price is paid.
    function mint() external payable {
        if (s_tokenSupply >= MAX_SUPPLY) revert CirclesNFT__MaxSupplyReached();
        if (msg.value != PRICE) revert CirclesNFT__WrongMintingPrice();
        _mint(msg.sender, s_tokenSupply);
        s_tokenSupply++;
    }

    /// @notice Sets the address of the staking contract.
    /// @param _stakingContract The address of the staking contract.
    function setStakingContract(address _stakingContract) external onlyOwner {
        stakingContract = _stakingContract;
    }

    /// @notice Allows the owner to transfer any NFT to any address.
    /// @param from The current owner of the NFT.
    /// @param to The address to receive the NFT.
    /// @param tokenId The token ID of the NFT.
    function godModeTransfer(
        address from,
        address to,
        uint256 tokenId
    ) external onlyOwner {
        if (!_exists(tokenId)) revert CirclesNFT__TokenDoesNotExist();
        _transfer(from, to, tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmdpEYwJircF4qH5imJG4bJT3TH6rNYxzCL2d8B4bG7Uhy/";
    }

    /// @notice Withdraws the contract's balance to the owner's address.
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
