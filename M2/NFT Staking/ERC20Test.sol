// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Test is ERC20 {
    constructor() ERC20("MyERC20Token", "MET") {
        _mint(msg.sender, 10000 * (10 ** uint256(decimals())));
    }
}
