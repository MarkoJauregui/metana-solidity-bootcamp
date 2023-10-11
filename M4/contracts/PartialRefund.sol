// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "hardhat/console.sol";

/**
 * @title ERC20 Token Sale with Partial Refund capability
 * @author Marko Jauregui
 * @notice This is a modified version of the TokenSale.sol contract, where users can mint and sell back tokens.
 */
contract PartialRefund is ERC20, Ownable, ReentrancyGuard {
    // Custom Errors
    error PartialRefund__SaleHasEnded();
    error PartialRefund__IncorrectMintingPrice();
    error PartialRefund__NoBalanceToWithdraw();
    error PartialRefund__TransferFailed();
    error PartialRefund__InsufficientEtherBalance();

    // Variables
    uint256 public constant MAX_SUPPLY = 1000000 * 10 ** 18;
    uint256 public constant TOKENS_PER_ETHER = 1000 * 10 ** 18;
    uint256 public constant ETHER_TO_WEI = 10 ** 18;
    uint256 public constant SELLBACK_RATIO = 500;
    uint256 public constant DECIMALS = 18;

    /**
     * @dev Contract constructor.
     * @param name Name of the ERC20 token.
     * @param symbol Symbol of the ERC20 token.
     */
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, 10000 * 10 ** 18);
    }

    /**
     * @dev Allows users to mint tokens.
     */
    function mintTokens() public payable nonReentrant {
        if (totalSupply() >= MAX_SUPPLY) revert PartialRefund__SaleHasEnded();
        if (msg.value != ETHER_TO_WEI)
            revert PartialRefund__IncorrectMintingPrice();

        uint256 tokensToMint = TOKENS_PER_ETHER;

        if (totalSupply() + tokensToMint >= MAX_SUPPLY) {
            tokensToMint = MAX_SUPPLY - totalSupply();
        }

        _mint(msg.sender, tokensToMint);
    }

    //!!!!!!!
    // UNCOMMENT THIS FUNCTION FOR TESTING PURPOSES
    // function adminMint(address to, uint256 amount) external onlyOwner {
    //     _mint(to, amount);
    // }
    ///////////////////////////////////////////////

    /**
     * @dev Allows users to sell back their tokens.
     * @param amount Amount of tokens to sell back.
     */
    function sellBack(uint256 amount) external nonReentrant {
        uint256 etherToPay = (amount * 0.5 ether) /
            (uint256(10 ** DECIMALS) * 1000);

        uint256 contractBalance = address(this).balance;

        // Debugging log
        console.log("etherToPay:", etherToPay);
        console.log("contractBalance:", contractBalance);

        if (contractBalance < etherToPay)
            revert PartialRefund__InsufficientEtherBalance();

        _burn(msg.sender, amount);
        (bool success, ) = payable(msg.sender).call{value: etherToPay}("");
        if (!success) revert PartialRefund__TransferFailed();
    }

    /**
     * @dev Allows owner to withdraw contract balance.
     */
    function withdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;

        if (contractBalance == 0) revert PartialRefund__NoBalanceToWithdraw();

        (bool success, ) = payable(owner()).call{value: contractBalance}("");
        if (!success) revert PartialRefund__TransferFailed();
    }

    /**
     * @dev Returns the maximum supply of the token.
     */
    function getMaxSupply() external pure returns (uint256) {
        return MAX_SUPPLY;
    }

    /**
     * @dev Returns the number of tokens minted per Ether.
     */
    function getTokensPerEther() external pure returns (uint256) {
        return TOKENS_PER_ETHER;
    }

    /**
     * @dev Allows users to mint tokens by sending Ether directly to the contract address.
     */
    receive() external payable {
        mintTokens();
    }
}
