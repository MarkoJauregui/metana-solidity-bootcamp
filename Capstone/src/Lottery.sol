// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2} from "@chainlink/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {KeeperCompatibleInterface} from "@chainlink/v0.8/automation/interfaces/KeeperCompatibleInterface.sol";
import {TicketNFT} from "./TicketNFT.sol";
import {WinnerNFT} from "./WinnerNFT.sol";

/// @title Decentralized NFT Lottery System
/// @dev Manages the NFT lottery system, including ticket sales, winner selection, and automated draws.
contract Lottery is VRFConsumerBaseV2, Ownable, KeeperCompatibleInterface {
    uint256 private s_ticketPrice;
    bool private s_lotteryActive;
    uint256 private s_lotteryPool;
    address[] private s_participants;
    uint256 private s_currentLotteryId;
    address private s_lastWinner;

    // Chainlink VRF variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint32 private constant CALLBACK_GAS_LIMIT = 100000;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // Timing for Chainlink Automation
    uint256 public lastLotteryStartTime;
    uint256 public interval = 24 hours;

    // NFT contracts
    TicketNFT private immutable s_ticketNFT;
    WinnerNFT private immutable s_winnerNFT;

    // Custom errors
    error LotteryAlreadyStarted();
    error LotteryNotActive();
    error InsufficientPayment(uint256 sent, uint256 required);
    error TransferFailed();

    // Events
    event LotteryStarted(uint256 lotteryId);
    event LotteryEnded(address winner, uint256 lotteryId);
    event TicketPurchased(
        address indexed buyer,
        uint256 amount,
        uint256 lotteryId
    );

    /// @notice Constructor to set initial values and Chainlink VRF details
    constructor(
        address vrfCoordinator,
        bytes32 keyHash,
        uint64 subscriptionId,
        address ticketNFTAddress,
        address winnerNFTAddress,
        address initialOwner,
        uint256 ticketPrice
    ) VRFConsumerBaseV2(vrfCoordinator) Ownable(initialOwner) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        s_ticketNFT = TicketNFT(ticketNFTAddress);
        s_winnerNFT = WinnerNFT(winnerNFTAddress);
        s_ticketPrice = ticketPrice;
        transferOwnership(initialOwner);
    }

    /// @notice Starts the lottery, allowing tickets to be purchased
    function startLottery(uint256 ticketPrice) public onlyOwner {
        if (s_lotteryActive) revert LotteryAlreadyStarted();
        s_ticketPrice = ticketPrice;
        s_lotteryActive = true;
        s_currentLotteryId++;
        lastLotteryStartTime = block.timestamp;
        emit LotteryStarted(s_currentLotteryId);
    }

    /// @notice Allows users to buy lottery tickets
    function buyTickets(uint256 amount) external payable {
        if (!s_lotteryActive) revert LotteryNotActive();
        uint256 requiredPayment = s_ticketPrice * amount;
        if (msg.value < requiredPayment)
            revert InsufficientPayment(msg.value, requiredPayment);

        for (uint256 i = 0; i < amount; i++) {
            s_participants.push(msg.sender);
        }

        s_lotteryPool += msg.value;
        s_ticketNFT.mint(msg.sender, s_currentLotteryId, amount, "");
        emit TicketPurchased(msg.sender, amount, s_currentLotteryId);
    }

    /// @notice Ends the lottery, selects a random winner, and resets the lottery
    function endLottery() public onlyOwner {
        if (!s_lotteryActive) revert LotteryNotActive();
        s_lotteryActive = false;
        requestRandomWinner();
    }

    /// @notice Requests randomness to select a lottery winner
    function requestRandomWinner() private {
        i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            NUM_WORDS
        );
    }

    /// @notice Callback function used by VRF Coordinator
    function fulfillRandomWords(
        uint256,
        uint256[] memory randomWords
    ) internal override {
        uint256 winnerIndex = randomWords[0] % s_participants.length;
        address winner = s_participants[winnerIndex];
        s_lastWinner = winner;
        (bool success, ) = winner.call{value: s_lotteryPool}("");
        if (!success) revert TransferFailed();
        s_winnerNFT.mint(winner);
        emit LotteryEnded(winner, s_currentLotteryId);
        s_lotteryPool = 0;
        delete s_participants;
    }

    /// @notice Keeper-compatible function to check if upkeep is needed
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded =
            (block.timestamp - lastLotteryStartTime) > interval &&
            s_lotteryActive;
        performData = ""; // Explicitly return an empty bytes array for the unused performData
    }

    /// @notice Keeper-compatible function to perform upkeep
    function performUpkeep(bytes calldata /* performData */) external override {
        require(
            (block.timestamp - lastLotteryStartTime) > interval,
            "Interval not reached"
        );
        require(s_lotteryActive, "Lottery not active");
        endLottery();
        startLottery(s_ticketPrice);
        lastLotteryStartTime = block.timestamp;
    }

    /// @notice Gets the current ticket price
    function getTicketPrice() external view returns (uint256) {
        return s_ticketPrice;
    }

    /// @notice Checks if the lottery is active
    function isLotteryActive() external view returns (bool) {
        return s_lotteryActive;
    }

    /// @notice Returns the total number of tickets purchased in the current lottery
    function getTotalTickets() external view returns (uint256) {
        return s_participants.length;
    }

    /// @notice Returns the address of the last winner
    function getLastWinner() external view returns (address) {
        require(s_lastWinner != address(0), "No winner selected yet");
        return s_lastWinner;
    }
}
