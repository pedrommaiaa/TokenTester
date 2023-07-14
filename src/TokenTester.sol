// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Vendor
import "forge-std/Test.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

// Tokens
import {BaseERC20} from "./tokens/BaseERC20.sol";

contract TokenTester is Test {
    IERC20 public tokenTest;

    address[] public tokens;
    string[] public tokenNames;
    string public tokensNameStr;

    enum Tokens {
        BaseERC20
    }

    constructor() {
        tokens.push(address(new BaseERC20("BaseERC20", "TST")));
        tokenNames.push("BaseERC20");

        uint256 length = tokenNames.length;
        for (uint256 i; i < length;) {
            tokensNameStr = string.concat(tokensNameStr, tokenNames[i]);
            tokensNameStr = string.concat(tokensNameStr, ",");
            unchecked { ++i; }
        }
    }

    modifier tokenTester(Tokens index) {
        // short circuit if TOKEN_TEST is not enabled
        bool enabled = vm.envOr("TOKEN_TEST", false);

        if (!enabled) {
            tokenTest = IERC20(tokens[uint256(index)]);
            _;            
            return;
        }

        // The ffi script will set `FORGE_TOKEN_TESTER_ID=n`
        uint256 envTokenId = vm.envOr("FORGE_TOKEN_TESTER_ID", uint256(0));

        if (envTokenId != 0) {
            tokenTest = IERC20(tokens[envTokenId - 1]);
            _;
        } else {
            bytes32 selector;

            assembly {
                selector := calldataload(0x0)
            }

            string[] memory inputs = new string[](5);
            inputs[0] = "node";
            inputs[1] = "test/external/testTokens.js";
            inputs[2] = Strings.toHexString(uint256(selector));
            inputs[3] = Strings.toHexString(uint256(tokens.length));
            inputs[4] = tokensNameStr;

            vm.ffi(inputs);
        }
    }
}
