// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Vendor
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract BaseERC4626 is ERC4626 {
    constructor(address underlying) ERC20("Token", "TKN") ERC4626(IERC20(underlying)) {}
}