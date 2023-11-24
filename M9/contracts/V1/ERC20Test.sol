// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC20Test is Initializable, ERC20Upgradeable {
    function initialize() public initializer {
        __ERC20_init("MyERC20Token", "MET");
        _mint(msg.sender, 10000 * (10 ** uint256(decimals())));
    }
}
