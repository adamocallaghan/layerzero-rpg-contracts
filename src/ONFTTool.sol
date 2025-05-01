// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

// import {ONFT721Enumerable} from "@layerzerolabs/onft-evm/contracts/onft721/ONFT721Enumerable.sol";
import {ONFT721} from "@layerzerolabs/onft-evm/contracts/onft721/ONFT721.sol";
import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {IONFT721, MessagingFee, MessagingReceipt, SendParam} from "@layerzerolabs/onft-evm/contracts/onft721/interfaces/IONFT721.sol";

interface ILayerZeroEndpointV2 {
    function eid() external view returns (uint32);
}

contract ONFTTool is ONFT721 {
    // Game Engine Contract
    address public gameEngine;

    uint256 public mintCount;

    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) ONFT721(_name, _symbol, _lzEndpoint, _delegate) {
        uint32 endpointID = ILayerZeroEndpointV2(_lzEndpoint).eid(); // get the endpoint ID
        if (endpointID == 40245) {
            for (uint256 i = 0; i < 15; i++) {
                _mint(_delegate, i);
            }
        } else if (endpointID == 40232) {
            for (uint256 i = 15; i < 30; i++) {
                _mint(_delegate, i);
            }
        }
    }

    function mint() public {
        _mint(msg.sender, mintCount);
        mintCount++;
    }

    function setGameEngine(address _gameEngine) public {
        // @note: add onlyDelegate modifier
        gameEngine = _gameEngine;
    }

    function mintToolToPlayer(address _player) public {
        // @note: add onlyGameEngine modifier
        // @note: add require/if to ensure player has:
        //        - a Character NFT
        //        - enough Gems tokens
        _mint(_player, mintCount);
        mintCount++;
    }

    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable override returns (MessagingReceipt memory msgReceipt) {
        // Use _refundAddress (EOA) as the sender in _debit()
        _debit(_refundAddress, _sendParam.tokenId, _sendParam.dstEid);

        (bytes memory message, bytes memory options) = _buildMsgAndOptions(
            _sendParam
        );

        // Send the message via LayerZero
        msgReceipt = _lzSend(
            _sendParam.dstEid,
            message,
            options,
            _fee,
            _refundAddress
        );

        emit ONFTSent(
            msgReceipt.guid,
            _sendParam.dstEid,
            _refundAddress,
            _sendParam.tokenId
        );
    }
}
