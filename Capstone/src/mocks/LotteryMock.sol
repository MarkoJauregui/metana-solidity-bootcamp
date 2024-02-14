// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Lottery.sol";

contract LotteryMock is Lottery {
    constructor(
        address vrfCoordinator,
        bytes32 keyHash,
        uint64 subscriptionId,
        address ticketNFTAddress,
        address winnerNFTAddress,
        address initialOwner,
        uint256 ticketPrice
    )
        Lottery(
            vrfCoordinator,
            keyHash,
            subscriptionId,
            ticketNFTAddress,
            winnerNFTAddress,
            initialOwner,
            ticketPrice
        )
    {}

    // Expose fulfillRandomWords through a public function for testing
    function fulfillRandomWordsPublic(
        uint256 requestId,
        uint256[] memory randomWords
    ) public {
        fulfillRandomWords(requestId, randomWords);
    }
}
