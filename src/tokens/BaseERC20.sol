// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Vendor
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BaseERC20 is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}
}