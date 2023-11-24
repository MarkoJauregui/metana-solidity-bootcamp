// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Test.sol";
import "./CirclesNFT.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title NFT Staking Contract
/// @notice Allows users to stake NFTs and earn ERC20 token rewards.
/// @dev Implements IERC721Receiver to handle receiving NFTs.
/// @author Marko Jauregui
contract NFTStaking is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    IERC721ReceiverUpgradeable
{
    error StakingContract__NotTokenOwner();
    error StakingContract__TooEarlyToWithdraw();
    error StakingContract__NotNFTOwner();

    ERC20Test private s_erc20Token;
    CirclesNFT private s_erc721Token;
    mapping(uint256 => address) public s_tokenOwner;
    mapping(uint256 => uint256) public s_lastWithdrawTime;

    modifier StakedTokenOwner(uint256 tokenId) {
        if (s_tokenOwner[tokenId] != msg.sender)
            revert StakingContract__NotTokenOwner();
        _;
    }

    function initialize(
        address erc20Address,
        address erc721Address
    ) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        s_erc20Token = ERC20Test(erc20Address);
        s_erc721Token = CirclesNFT(erc721Address);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        s_tokenOwner[tokenId] = from;
        s_lastWithdrawTime[tokenId] = block.timestamp;
        return this.onERC721Received.selector;
    }

    /// @notice Stakes an NFT in the contract.
    /// @param tokenId The ID of the NFT to be staked.
    function stakeNFT(uint256 tokenId) external {
        if (msg.sender != s_erc721Token.ownerOf(tokenId))
            revert StakingContract__NotNFTOwner();
        s_erc721Token.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    /// @notice Withdraws ERC20 reward tokens for a staked NFT.
    /// @param tokenId The ID of the staked NFT.
    function withdrawERC20(
        uint256 tokenId
    ) external nonReentrant StakedTokenOwner(tokenId) {
        if (block.timestamp < s_lastWithdrawTime[tokenId] + 1 days)
            revert StakingContract__TooEarlyToWithdraw();
        s_erc20Token.transfer(
            msg.sender,
            10 * (10 ** uint256(s_erc20Token.decimals()))
        );
        s_lastWithdrawTime[tokenId] = block.timestamp;
    }

    /// @notice Unstakes an NFT and returns it to its owner.
    /// @param tokenId The ID of the NFT to be unstaked.
    function unstakeNFT(
        uint256 tokenId
    ) external nonReentrant StakedTokenOwner(tokenId) {
        s_erc721Token.safeTransferFrom(address(this), msg.sender, tokenId);
        delete s_tokenOwner[tokenId];
        delete s_lastWithdrawTime[tokenId];
    }
}
