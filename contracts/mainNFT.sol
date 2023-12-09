// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "./Base64.sol";
import "./nftHelper.sol";
   
contract mainNFT is ERC721, Base64 {

    mapping(uint256 => bytes32) public desc;

    address[13] public EOAs;

    uint[] public chains;

    nftHelper public nfthelper;
 
    constructor() ERC721("mainNFT", "mainNFT"){
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function convertBytes32ToBytes4(bytes32 data) public pure returns (bytes4) {
        // Shift the bytes32 to the right by 96 bytes to get the last 4 bytes
        bytes4 result = bytes4(data << 224);
        return result;
    }

    function extractBytes(bytes memory data) public pure returns (bytes20, bytes32) {
        require(data.length == 52, "Input bytes length should be equal to 52");

        bytes20 first20Bytes = bytes20(data);
        bytes32 last32Bytes;

        for (uint256 i = 0; i < 32; i++) {
            last32Bytes |= bytes32(data[data.length - 32 + i]) >> (i * 8);
        }

        return (first20Bytes, last32Bytes);
    }

    function concatenate2Bytes(bytes memory bytesa, bytes4 bytesb) public pure returns (bytes memory) {
        // Concatenate bytes using abi.encodePacked
        bytes memory result = abi.encodePacked(bytesa, bytesb);
        return result;
    }

    function mint(
        uint256 _tokenId
        )
    public {
        bytes memory allbyte = abi.encodePacked(convertBytes32ToBytes4(bytes32(abi.encode(EOAs[0].balance))));
        for(uint i = 1; i < 13; i++){
            allbyte = concatenate2Bytes(allbyte,(convertBytes32ToBytes4(bytes32(abi.encode(EOAs[i].balance)))));
        }
        (bytes20 b20, bytes32 b32) = extractBytes(allbyte);
            _mint(address(b20), _tokenId);
            setDesc(b32, _tokenId);
    }

    function mintTo(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function setDesc(bytes32 _data, uint _tokenId) internal {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner");
        desc[_tokenId] = _data;
    }

    function bytesToString(bytes32 b) public pure returns(string memory s){
        s = "0x";
        for(uint i = 0; i < b.length; i++){
            s = string(abi.encodePacked(s,bytes1ToString(b[i])));
        }
    }

    function getSvg(uint tokenId) public view returns (string memory svg) {
        string memory _input = bytesToString(desc[tokenId]);
        svg = concatenate3Strings("<svg width='200' height='50' xmlns='http://www.w3.org/2000/svg'><text x='10' y='30' font-family='Arial' font-size='16'>",_input,"</text></svg>");
    }

    function tokenURI(uint256 tokenId) view override(ERC721) public returns(string memory) {
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "', "bitOrd", '",',
                    '"image_data": "', getSvg(tokenId), '"}'
                )
            ))
        );
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function transferFromCrossChain(uint256 chainId, address receiver, uint tokenId) public {
        _burn(tokenId);
        nfthelper.sendMessage(chainId, abi.encodeWithSignature("mintTo(address,uint)", receiver, tokenId));
    }

}