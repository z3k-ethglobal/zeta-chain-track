// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import "@openzeppelin/token/ERC721/ERC721.sol";
import {Base64} from "./Base64.sol";

contract BitcoinOrdinals is zContract, ERC721, Base64{

    SystemContract public immutable systemContract;

    uint public lastToken;

    mapping(uint256 => info) public desc;

        struct info {
        bytes data;                   // metadata
    }

    constructor(address systemContractAddress) ERC721("BitOrd", "BitOrd"){
        systemContract = SystemContract(systemContractAddress);
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
        mint(BytesHelperLib.bytesToAddress(context.origin, 0),message);

    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
        address zrc20 = systemContract.gasCoinZRC20ByChainId(18332);
        (, uint256 gasFee) = IZRC20(zrc20).withdrawGasFee();

        IZRC20(zrc20).approve(zrc20, gasFee);
        IZRC20(zrc20).withdraw(abi.encode(_ownerOf(tokenId)), 1);
    }

    function mint(
        address to, 
        bytes memory _data) 
    public {
        _safeMint(to, lastToken);
        setDesc(_data, lastToken);
        lastToken++;
    }

    function setDesc(bytes memory _data, uint _tokenId) internal {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner");
        desc[_tokenId] = info(_data);
    }

    function addressToString(address _address) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_address)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }

        return string(str);
    }

    function boolToString(bool _bool) internal pure returns (string memory) {
        if (_bool) {
            return "true";
        } else {
            return "false";
        }
    }

    function getSvg(uint tokenId) public view returns (string memory svg) {
        string memory _input = bytesToString(desc[tokenId].data);
        svg = concatenateStrings("<svg width='200' height='50' xmlns='http://www.w3.org/2000/svg'><text x='10' y='30' font-family='Arial' font-size='16'>",_input,"</text></svg>");
    }    

    function tokenURI(uint256 tokenId) view override(ERC721) public returns(string memory) {
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "', "BitOrd", '",',
                    '"image_data": "', getSvg(tokenId), '"}'
                )
            ))
        );
        return string(abi.encodePacked('data:application/json;base64,', json));
    }    
}
