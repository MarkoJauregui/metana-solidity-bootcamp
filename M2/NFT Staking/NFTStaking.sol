// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Statements
import "./ERC20Test.sol";
import "./CirclesNFT3.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTStaking is Ownable, ReentrancyGuard, IERC721Receiver {
    // Custom Errors
    error StakingContract__NotTokenOwner();
    error StakingContract__TooEarlyToWithdraw();
    
    // State Variables
    ERC20Test private s_erc20Token;
    CirclesNFT3 private s_erc721Token;
    
    /// @notice Mapping to track the owner of a staked NFT.  
    /// @dev tokenId => owner address
    mapping(uint256 => address) public s_tokenOwner;
    
    /// @notice Mapping to track the last withdrawal time of ERC20 tokens for a staked NFT.
    /// @dev tokenId => last withdrawal timestamp
    mapping(uint256 => uint256) public s_lastWithdrawTime;
    
    // Modifiers
    modifier StakedTokenOwner(uint256 tokenId) {
        if(s_tokenOwner[tokenId] != msg.sender) revert StakingContract__NotTokenOwner();
        _;
    }
    
    // Constructor
    constructor(address erc20Address, address erc721Address){
        s_erc20Token = ERC20Test(erc20Address);
        s_erc721Token = CirclesNFT3(erc721Address);
    }
    
    // Functions
    
    /// @notice Implementation of the IERC721Receiver interface to safely receive ERC721 tokens.
    /// @dev This will be called automatically when a user transfers their NFT to this contract.
    /// @param operator The address which called `safeTransferFrom` function.
    /// @param from The address which previously owned the token.
    /// @param tokenId The NFT identifier which is being transferred.
    /// @param data Additional data with no specified format.
    function onERC721Received(
        address operator, 
        address from, 
        uint256 tokenId, 
        bytes calldata data
    ) 
        external 
        override 
        returns (bytes4) 
    {
        s_tokenOwner[tokenId] = from;
        s_lastWithdrawTime[tokenId] = block.timestamp;
        return this.onERC721Received.selector;
    }
    
    /// @notice Allows the owner of a staked NFT to withdraw their ERC20 rewards.
    /// @dev Transfers ERC20 tokens to the owner and updates the withdrawal time.
    /// @param tokenId The ID of the staked NFT.
    function withdrawERC20(uint256 tokenId) external nonReentrant StakedTokenOwner(tokenId) {
        if(block.timestamp < s_lastWithdrawTime[tokenId] + 1 days) revert StakingContract__TooEarlyToWithdraw();
        s_erc20Token.transfer(msg.sender, 10 * (10 ** uint256(s_erc20Token.decimals())));
        s_lastWithdrawTime[tokenId] = block.timestamp;
    }
    
    /// @notice Allows the owner of a staked NFT to unstake and retrieve their NFT.
    /// @dev Transfers the NFT back to the owner and removes it from staking.
    /// @param tokenId The ID of the staked NFT.
    function unstakeNFT(uint256 tokenId) external nonReentrant StakedTokenOwner(tokenId) {
        s_erc721Token.safeTransferFrom(address(this), msg.sender, tokenId);
        delete s_tokenOwner[tokenId];
        delete s_lastWithdrawTime[tokenId];
    }
}

