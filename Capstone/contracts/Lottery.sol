// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "./TicketNFT.sol"; // Ensure this path is correct
import "./WinnerNFT.sol"; // Ensure this path is correct

/// @title Decentralized NFT Lottery System
/// @dev Manages the NFT lottery system, including ticket sales and winner selection.
contract Lottery is VRFConsumerBaseV2, Ownable {
    uint256 private s_ticketPrice;
    bool private s_lotteryActive;
    uint256 private s_lotteryPool;
    address[] private s_participants;
    uint256 private s_currentLotteryId;

    // Chainlink VRF variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint32 private constant CALLBACK_GAS_LIMIT = 100000;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // NFT contracts
    TicketNFT private immutable s_ticketNFT;
    WinnerNFT private immutable s_winnerNFT;

    // Custom errors
    error Lottery__LotteryAlreadyStarted();
    error Lottery__LotteryNotActive();
    error Lottery__InsufficientPayment(uint256 sent, uint256 required);
    error Lottery__TransferFailed();

    // Events
    event LotteryStarted(uint256 lotteryId);
    event LotteryEnded(address winner, uint256 lotteryId);
    event TicketPurchased(
        address indexed buyer,
        uint256 amount,
        uint256 lotteryId
    );

    /// @notice Constructor to set initial values and Chainlink VRF details
    /// @param vrfCoordinator The address of the Chainlink VRF Coordinator
    /// @param keyHash The key hash for the Chainlink VRF
    /// @param subscriptionId The subscription ID for the Chainlink VRF
    /// @param ticketNFTAddress The address of the TicketNFT contract
    /// @param winnerNFTAddress The address of the WinnerNFT contract
    constructor(
        address vrfCoordinator,
        bytes32 keyHash,
        uint64 subscriptionId,
        address ticketNFTAddress,
        address winnerNFTAddress,
        address initialOwner
    ) VRFConsumerBaseV2(vrfCoordinator) Ownable(initialOwner) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        s_ticketNFT = TicketNFT(ticketNFTAddress);
        s_winnerNFT = WinnerNFT(winnerNFTAddress);
        transferOwnership(msg.sender); // Set the owner
    }

    /// @notice Starts the lottery, allowing tickets to be purchased
    /// @param ticketPrice The price of a single lottery ticket
    function startLottery(uint256 ticketPrice) external onlyOwner {
        if (s_lotteryActive) revert Lottery__LotteryAlreadyStarted();
        s_ticketPrice = ticketPrice;
        s_lotteryActive = true;
        s_currentLotteryId++;
        emit LotteryStarted(s_currentLotteryId);
    }

    /// @notice Allows users to buy lottery tickets
    /// @param amount The number of tickets to buy
    function buyTickets(uint256 amount) external payable {
        if (!s_lotteryActive) revert Lottery__LotteryNotActive();
        uint256 requiredPayment = s_ticketPrice * amount;
        if (msg.value < requiredPayment)
            revert Lottery__InsufficientPayment(msg.value, requiredPayment);

        for (uint256 i = 0; i < amount; i++) {
            s_participants.push(msg.sender);
        }

        s_lotteryPool += msg.value;
        s_ticketNFT.mint(msg.sender, s_currentLotteryId, amount, "");
        emit TicketPurchased(msg.sender, amount, s_currentLotteryId);
    }

    /// @notice Ends the lottery, selects a random winner, and resets the lottery
    function endLottery() external onlyOwner {
        if (!s_lotteryActive) revert Lottery__LotteryNotActive();
        s_lotteryActive = false;
        requestRandomWinner();
    }

    /// @notice Requests randomness to select a lottery winner
    function requestRandomWinner() private {
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            NUM_WORDS
        );
    }

    /// @notice Callback function used by VRF Coordinator
    /// @param randomWords The array of random values returned by VRF Coordinator
    function fulfillRandomWords(
        uint256, // requestId
        uint256[] memory randomWords
    ) internal override {
        uint256 winnerIndex = randomWords[0] % s_participants.length;
        address winner = s_participants[winnerIndex];
        (bool success, ) = winner.call{value: s_lotteryPool}("");
        if (!success) revert Lottery__TransferFailed();
        s_winnerNFT.mint(winner);
        emit LotteryEnded(winner, s_currentLotteryId);
        // Reset the lottery for the next round
        s_lotteryPool = 0;
        delete s_participants;
    }

    /// @notice Gets the current ticket price
    /// @return The price of a lottery ticket
    function getTicketPrice() external view returns (uint256) {
        return s_ticketPrice;
    }

    /// @notice Checks if the lottery is active
    /// @return True if the lottery is active, false otherwise
    function isLotteryActive() external view returns (bool) {
        return s_lotteryActive;
    }

    /// @notice Returns the total number of tickets purchased in the current lottery
    /// @return The total number of tickets
    function getTotalTickets() external view returns (uint256) {
        return s_participants.length;
    }
}
