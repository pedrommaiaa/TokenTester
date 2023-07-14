// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BaseERC20} from "./BaseERC20.sol";

contract ERC20HighDecimals is BaseERC20 {
    function decimals() public pure override returns (uint8) {
        return 50;
    }
}