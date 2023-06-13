// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console2} from "../lib/forge-std/src/console2.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {Osiris} from "../src/Osiris.sol";

contract Deploy is Script {
    Osiris golpe;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        golpe = new Osiris{value: 100 ether}();
        console2.log(address(golpe));

        vm.stopBroadcast();
    }
}
