// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console2} from "../lib/forge-std/src/console2.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {Counter} from "../src/Counter.sol";
import {Flipper} from "../src/Flipper.sol";

contract Deploy is Script {
    Counter counter;
    Flipper flipper;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        counter = new Counter();
        flipper = new Flipper();

        vm.stopBroadcast();
    }
}
