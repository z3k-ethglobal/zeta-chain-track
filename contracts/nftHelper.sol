// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@zetachain/protocol-contracts/contracts/evm/tools/ZetaInteractor.sol";
import "@zetachain/protocol-contracts/contracts/evm/interfaces/ZetaInterfaces.sol";

import "./mainNFT.sol";

contract nftHelper is ZetaInteractor, ZetaReceiver {
    error InvalidMessageType();

    event CrossChainMessageEvent(bytes);
    event CrossChainMessageRevertedEvent(bytes);

    bytes32 public constant OMNINFT_MESSAGE_MESSAGE_TYPE =
        keccak256("OMNINFTisthefuture");
    ZetaTokenConsumer private immutable _zetaConsumer;
    IERC20 internal immutable _zetaToken;

    address public nftContract;

    constructor(
        address connectorAddress,
        address zetaTokenAddress,
        address zetaConsumerAddress,
        address _nftContract
    ) ZetaInteractor(connectorAddress) {
        _zetaToken = IERC20(zetaTokenAddress);
        _zetaConsumer = ZetaTokenConsumer(zetaConsumerAddress);
        nftContract = _nftContract;
    }

    function sendMessage(
        uint256 destinationChainId,
        bytes memory message
    ) external payable {
        if (!_isValidChainId(destinationChainId))
            revert InvalidDestinationChainId();

        uint256 crossChainGas = 2 * (10 ** 18);
        uint256 zetaValueAndGas = _zetaConsumer.getZetaFromEth{
            value: msg.value
        }(address(this), crossChainGas);
        _zetaToken.approve(address(connector), zetaValueAndGas);

        connector.send(
            ZetaInterfaces.SendInput({
                destinationChainId: destinationChainId,
                destinationAddress: interactorsByChainId[destinationChainId],
                destinationGasLimit: 300000,
                message: abi.encode(OMNINFT_MESSAGE_MESSAGE_TYPE, message),
                zetaValueAndGas: zetaValueAndGas,
                zetaParams: abi.encode("")
            })
        );
    }

    function onZetaMessage(
        ZetaInterfaces.ZetaMessage calldata zetaMessage
    ) external override isValidMessageCall(zetaMessage) {
        (bytes32 messageType, bytes memory message) = abi.decode(
            zetaMessage.message,
            (bytes32, bytes)
        );

        if (messageType != OMNINFT_MESSAGE_MESSAGE_TYPE)
            revert InvalidMessageType();

        emit CrossChainMessageEvent(message);

        nftContract.call(message);
    }

    function onZetaRevert(
        ZetaInterfaces.ZetaRevert calldata zetaRevert
    ) external override isValidRevertCall(zetaRevert) {
        (bytes32 messageType, bytes memory message) = abi.decode(
            zetaRevert.message,
            (bytes32, bytes)
        );

        if (messageType != OMNINFT_MESSAGE_MESSAGE_TYPE)
            revert InvalidMessageType();

        emit CrossChainMessageRevertedEvent(message);
    }
}