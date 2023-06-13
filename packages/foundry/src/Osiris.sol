// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Osiris {
    address public immutable farao;
    mapping(address => uint256) public saldoETH;
    mapping(address => uint256) public saldoNFT;
    mapping(address => address) public referenciador;
    mapping(address => uint256) public dataEntrada;

    uint256 public constant TEMPO_BLOQUEIO = 1 minutes;

    error PrecisaSerMultiplo100ETH(string message);
    error DestinatarioInvalido(string message);
    error TahCedoAinda(uint256 minutosRestantes);
    error ValorInsuficiente(string message);
    error SaldoInsuficiente(string message);
    error SuaPromesaKKK(uint256 seuSaldo);
    error AtaqueReentrada(string message);
    error NFTNecessario(string message);
    error VcTemConvites(uint256 NFTs);

    event MaisUmPaPaPa(
        address novoUsuario,
        address referenciador,
        uint256 valorPago
    );
    event MaisNFT(address usuario, uint256 valorPago);

    constructor() payable {
        if (msg.value < 100 ether) {
            revert ValorInsuficiente("Valor > 100 ETH");
        }
        farao = msg.sender;
        saldoETH[farao] = 100 ether;
        saldoNFT[farao] = 100;
    }

    function entrarNoEsquema(address referenciadorAddress) external payable {
        if (msg.value < 100 ether) {
            revert ValorInsuficiente("Valor >= 100 ETH");
        }
        if (saldoNFT[msg.sender] == 0) {
            revert NFTNecessario("Vc precisa de um convite NFT");
        }

        saldoETH[msg.sender] +=  msg.value;

        // Transferir 90 ETH para o referenciador
        saldoETH[referenciadorAddress] += msg.value * 0.9 ether;
        // Transferir 10 ETH para o referenciador do referenciador
        saldoETH[referenciador[referenciadorAddress]] += msg.value * 0.10 ether;
        // Registrar o referenciador do novo usuário
        referenciador[msg.sender] = referenciadorAddress;
        // Registrar a data de entrada do novo usuário
        dataEntrada[msg.sender] = block.timestamp;

        emit MaisUmPaPaPa(msg.sender, referenciadorAddress, msg.value);
    }

    function pegarConvitesNFT() external payable {
        if (msg.value < 100 ether) {
            revert ValorInsuficiente("Valor > 100 EHT");
        }
        if (msg.value % 100 ether != 0) {
            revert PrecisaSerMultiplo100ETH("Cada NFT custa 100 EHT");
        }
        if (saldoNFT[msg.sender] == 0) {
            revert NFTNecessario("Apenas membros podem adquirir novos NFT");
        }

        // Calcular a quantidade de NFTs a serem atribuídos
        uint256 quantidadeNFT = msg.value / 100 ether;
        // Transferir 90% dos ETH para o referenciador
        saldoETH[referenciador[msg.sender]] += (msg.value * 9) / 10;
        // Transferir 10% dos ETH para o referenciador do referenciador
        saldoETH[referenciador[referenciador[msg.sender]]] += msg.value / 10;

        // Atribuir os NFTs ao novo usuário
        saldoNFT[msg.sender] += quantidadeNFT;

        emit MaisNFT(msg.sender, msg.value);
    }

    function tenteSacar() external {
        if (saldoETH[msg.sender] < 100 ether) {
            revert SaldoInsuficiente("Saldo insuficiente para saque");
        }
        if (block.timestamp < dataEntrada[msg.sender] + TEMPO_BLOQUEIO) {
            uint256 minutosRestantes = (dataEntrada[msg.sender] +
                TEMPO_BLOQUEIO -
                block.timestamp) / 1 minutes;
            revert TahCedoAinda(minutosRestantes);
        }

        // Reduzir o saldo ETH do usuário
        uint256 saldo = saldoETH[msg.sender];
        saldoETH[msg.sender] = 0;


        // 30 dias * 2 (Dobro)
        if (block.timestamp >= dataEntrada[msg.sender] + (TEMPO_BLOQUEIO * 2)) {
            payable(msg.sender).transfer(saldo * 2);
        }
        // 60 dias * 3 (Triplo)
        if (block.timestamp >= dataEntrada[msg.sender] + (TEMPO_BLOQUEIO * 3)) {
            payable(msg.sender).transfer(saldo * 3);
        }
        // 90 dias * 3 (Quadruplo)
        if (block.timestamp >= dataEntrada[msg.sender] + (TEMPO_BLOQUEIO * 4)) {
            payable(msg.sender).transfer(saldo * 4);
        }
    }

    function saldoTotal() public view returns (uint256) {
        return address(this).balance;
    }

    function convidarKKK(address to) public {
        if (to == address(0)) {
            revert DestinatarioInvalido("Nao pode ser 0x");
        }
        if (saldoNFT[msg.sender] == 0) {
            revert NFTNecessario("Vc precisa de um convite NFT");
        }

        unchecked {
            saldoNFT[msg.sender]--;
            saldoNFT[to]++;
        }
    }

    function meuSaldoETH() external {
        revert SuaPromesaKKK(saldoETH[msg.sender]);
    }

    function meuSaldoNFT() external {
        revert VcTemConvites(saldoNFT[msg.sender]);
    }
}
