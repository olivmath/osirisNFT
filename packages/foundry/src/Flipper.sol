// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Flipper {
    bool public data;

    function flip() public {
        data = !data;
    }
}
