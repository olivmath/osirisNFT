// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Osiris.sol";

contract GolpeTest is Test {
    Osiris golpe;
    address farao = address(0x666);
    address meninoBom = address(0x01);

    function setUp() public {
        vm.deal(farao, 100 ether);
        vm.deal(meninoBom, 100 ether);

        vm.prank(farao);
        golpe = new Osiris{value: 100 ether}();
    }

    function test_initialBalance() public {
        assertEq(golpe.saldoTotal(), 100 ether);
    }

    function test_addPaPaPa() public {
        vm.prank(farao);
        golpe.convidarKKK(meninoBom);

        vm.prank(meninoBom);
        golpe.entrarNoEsquema{value: 100 ether}(farao);

        assertEq(farao, golpe.referenciador(meninoBom));
        assertEq(100 ether, golpe.saldoETH(meninoBom));
        assertEq(1, golpe.dataEntrada(meninoBom));
        assertEq(200 ether, golpe.saldoTotal());
        assertEq(1, golpe.saldoNFT(meninoBom));
    }
}
