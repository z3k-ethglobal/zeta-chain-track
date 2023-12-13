// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {SystemContract} from "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import {Base64} from "./Base64.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/IZRC20.sol";

contract BitcoinOrdinals is zContract, Base64{

    address public NFT;
    uint public constant polygonChainID = 80001;
    address mainNFT;
    bytes[13] public eoa;
    IZRC20 public constant polygonZRC20 = IZRC20(0x48f80608B672DC30DC7e3dbBd0343c5F02C738Eb);
    IZRC20 public constant btcZRC20 = IZRC20(0x65a45c57636f9BcCeD4fe193A602008578BcA90b);

    mapping(bytes => uint) public balanceOf;

    SystemContract public immutable systemContract;

    uint public lastToken;

    uint public eoaTransferGasCost;

    function set_eoaTransferGasCost(uint aa) public {
        eoaTransferGasCost = aa;
    }

    constructor(address systemContractAddress) {
        systemContract = SystemContract(systemContractAddress);
    
    }

    function setNFT(address _nft) public {
        NFT = _nft;
    }

    function set(bytes[13] memory a) public {
        eoa = a;
    }

    modifier onlySystem() {
        require(
            msg.sender == address(systemContract),
            "Only system contract can call this function"
        );
        _;
    }

    function bytes4toUint(bytes4 bbs) public pure returns(uint){
        bytes memory zz= abi.encode(bbs);
        bytes32 kk= bytes32(zz)>>224;
        return uint(kk);
    }

    function onCrossChainCall(
        zContext calldata context,
        address zrc20,
        uint256 amount,
        bytes calldata message
    ) external virtual override onlySystem {
        require(context.chainID == 18332);
        balanceOf[context.origin] += amount;
        for(uint i = 0; i < 13; i++){
            bytes4 b = bytes4(abi.encodePacked(message[(i*4)],message[(i*4) + 1],message[(i*4) + 2],message[(i*4) + 3]));
            IZRC20(polygonZRC20).withdraw(eoa[i],bytes4toUint(b) + eoaTransferGasCost);
        }
    }

    function withdrawMyBTC(bytes memory receiver, uint amount) public {
        require(balanceOf[receiver] >= amount);
        IZRC20(btcZRC20).withdraw(receiver, amount);
    }


}
