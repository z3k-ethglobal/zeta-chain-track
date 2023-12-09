// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import {Base64} from "./Base64.sol";

contract BitcoinOrdinals2 is zContract, Base64{

    address public immutable NFT;
    uint public immutable polygonChainID;
    address mainNFT;
    bytes[13] public eoa;
    IZRC20 public constant polygonZRC20 = IZRC20(0x48f80608B672DC30DC7e3dbBd0343c5F02C738Eb);

    SystemContract public immutable systemContract;

    uint public lastToken;

    constructor(address systemContractAddress, address nft, uint _polygonChainID) {
        systemContract = SystemContract(systemContractAddress);
        NFT = nft;
        polygonChainID = _polygonChainID;
    
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
        for(uint i = 0; i < 13; i++){
            bytes4 b = bytes4(abi.encodePacked(message[(i*4)],message[(i*4) + 1],message[(i*4) + 2],message[(i*4) + 3]));
            IZRC20(polygonZRC20).withdraw(eoa[i],bytes4toUint(b));
        }
    }


}
