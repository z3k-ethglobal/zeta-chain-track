// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/token/ERC721/ERC721.sol";
import {Base64} from "./Base64.sol";

contract BitcoinOrdinals is ERC721, Base64 {

    address public immutable OmniContract;

    mapping(uint256 => info) public desc;

        struct info {
        string name;                  // name that the user wants to give to their nft
        bytes data;                   // metadata
    }

    constructor(address _omni) ERC721("Track", "TRACK") {
        OmniContract = _omni;
    }

    modifier onlyOmni() {
        require(msg.sender == OmniContract);
        _;
    }

    function _burn(uint256 tokenId) internal override(ERC721) onlyOmni{
        super._burn(tokenId);

    }

    function mint(
        address to, 
        uint256 _tokenId, 
        string memory _name,
        address _target,
        bytes memory _data,
        uint _datatype) 
    public onlyOmni{
        _safeMint(to, _tokenId);
        setDesc(_target, _data, _tokenId, _name);
    }

    function setDesc(address _target, bytes memory _data, uint _tokenId, string memory _name) internal onlyOmni{
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner");
        desc[_tokenId] = info(_name, _data);
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
        string memory output;
        string memory _input = bytesToString(desc[tokenId].data);
        svg = concatenateStrings("<svg width='200' height='50' xmlns='http://www.w3.org/2000/svg'><text x='10' y='30' font-family='Arial' font-size='16'>",_input,"</text></svg>");
    }    

    function tokenURI(uint256 tokenId) view override(ERC721) public returns(string memory) {
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "', desc[tokenId].name, '",',
                    '"image_data": "', getSvg(tokenId), '"}'
                )
            ))
        );
        return string(abi.encodePacked('data:application/json;base64,', json));
    }    
}