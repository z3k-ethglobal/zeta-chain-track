// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import {Base64} from "./Base64.sol";
import "@zetachain/protocol-contracts/contracts/zevm/ZRC20.sol";

contract BitcoinOrdinals2 is zContract, Base64{

    address public immutable NFT;
    uint public immutable polygonChain;
    address mainNFT;

    SystemContract public immutable systemContract;

    uint public lastToken;

    mapping(uint256 => info) public desc;

        struct info {
        bytes data;                   // metadata
    }

    constructor(address systemContractAddress, address nft, address _polygonChain) {
        systemContract = SystemContract(systemContractAddress);
        NFT = nft;
        polygonChain = _polygonChain;
    
    }

    modifier onlySystem() {
        require(
            msg.sender == address(systemContract),
            "Only system contract can call this function"
        );
        _;
    }

    function onCrossChainCall(
        zContext calldata context,
        address zrc20,
        uint256 amount,
        bytes calldata message
    ) external virtual override onlySystem {
        require(context.chainID == 18332);
        for(uint i = 0; i < 13; i++){

            ZRC20(systemContract.gasCoinZRC20ByChainId(polygonChain)).withdraw(mainNFT, amount);
        }
    }

}
