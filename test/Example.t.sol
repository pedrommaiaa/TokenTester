// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Vendor
import "forge-std/Test.sol";

import {TokenTester} from "../src/TokenTester.sol";
import {BaseERC4626} from "../src/tokens/BaseERC4626.sol";

contract ExampleTest is Test, TokenTester {
    address alice = makeAddr("ALICE");
    BaseERC4626 vault;
    
    function setUp() public {}

    function testDeposit() external tokenTester(Tokens.BaseERC20) {
        vault = new BaseERC4626(address(tokenTest));
        deal(address(tokenTest), alice, 100);

        vm.startPrank(alice);
        tokenTest.approve(address(vault), 100);
        vault.deposit(100, alice);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 100);
    }
}