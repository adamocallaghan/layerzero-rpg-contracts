// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {IONFT721, MessagingFee, MessagingReceipt, SendParam} from "@layerzerolabs/onft-evm/contracts/onft721/interfaces/IONFT721.sol";
import {IOFT} from "lib/devtools/packages/oft-evm/contracts/interfaces/IOFT.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IOFTGems, IONFTCharacter, IONFTTool} from "./interfaces/GameInterfaces.sol";
import {AddressCast} from "../utils/AddressCast.sol";
// import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

interface ILayerZeroEndpointV2 {
    function eid() external view returns (uint32);
}

struct OftSendParam {
    uint32 dstEid; // Destination endpoint ID.
    bytes32 to; // Recipient address.
    uint256 amountLD; // Amount to send in local decimals.
    uint256 minAmountLD; // Minimum amount to send in local decimals.
    bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
    bytes composeMsg; // The composed message for the send() operation.
    bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
}

// struct OftSendParam {
//     uint32 dstEid; // Destination endpoint ID.
//     bytes32 to; // Recipient address.
//     uint256 amountLD; // Amount to send in local decimals.
//     uint256 minAmountLD; // Minimum amount to send in local decimals.
//     bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
//     bytes composeMsg; // The composed message for the send() operation.
//     bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
// }

// struct SendParam {
//     uint32 dstEid; // Destination LayerZero EndpointV2 ID.
//     bytes32 to; // Recipient address.
//     uint256 tokenId;
//     bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
//     bytes composeMsg; // The composed message for the send() operation.
//     bytes onftCmd; // The ONFT command to be executed, unused in default ONFT implementations.
// }

// struct MessagingFee {
//     uint256 nativeFee;
//     uint256 lzTokenFee;
// }

contract OAppGameEngine is OApp {
    // ====================
    // === STORAGE VARS ===
    // ====================

    IONFTCharacter public characterONFT;
    IONFTTool public toolONFT;
    IOFTGems public gemsOFT;

    enum Level {
        Village,
        Woods,
        Mountain,
        Crypts
    }

    // ==============
    // === ERRORS ===
    // ==============

    error Error__NotEnoughGemsToMint(uint256 _playerGemsBalance);
    error Error__NotEnoughGemsToBridge(uint256 _playerGemsBalance);
    error Error__ToolCannotBeMintedOnThisChain();
    error Error__TooManyGems();

    // ==============
    // === EVENTS ===
    // ==============

    event CharacterMinted(address);
    event ToolMinted(address);
    event GemsMinted(address, uint256);

    // ===================
    // === CONSTRUCTOR ===
    // ===================

    constructor(
        address _endpoint,
        address _delegate,
        address _characterContract,
        address _toolContract,
        address _gemsContract
    ) OApp(_endpoint, _delegate) Ownable(_delegate) {
        characterONFT = IONFTCharacter(_characterContract);
        toolONFT = IONFTTool(_toolContract);
        gemsOFT = IOFTGems(_gemsContract);
    }

    // =================
    // === MINT GEMS ===
    // =================

    // @note: in a production level game we would protect this function and call it
    // from a backend/server wallet or something like that. However, we're going
    // to pretend here that our users *won't* interact with the contract directly
    // to just mint a load of gems and will play the level to get them instead

    function mintGems(address _player, uint256 _amount) public {
        if (_amount > 10) {
            revert Error__TooManyGems();
        }
        gemsOFT.mintGemsToPlayer(_player, _amount);
        emit GemsMinted(_player, _amount);
    }

    // ======================
    // === MINT CHARACTER ===
    // ======================

    function mintCharacter(address _player) public {
        characterONFT.mintCharacterToPlayer(_player);
        emit CharacterMinted(_player);
    }

    // =================
    // === MINT TOOL ===
    // =================

    // @note: so, in order to mint the tool, we want our users to:
    //          - have the full 10 gems from level 1
    //          - have bridged over to Optimism Sepolia

    function mintTool(address _player) public {
        // get users gem balance
        uint256 userGemsBalance = gemsOFT.balanceOf(_player);
        if (userGemsBalance < 10) {
            // 10 == finished the level & can mint tool
            revert Error__NotEnoughGemsToMint(userGemsBalance);
        }
        // @todo: burn the player's gems here
        uint32 endpointID = endpoint.eid(); // get the endpoint ID
        if (endpointID != 40232) {
            revert Error__ToolCannotBeMintedOnThisChain(); // tool can only be minted on Op Sepolia!
        }
        toolONFT.mintToolToPlayer(_player);
        emit ToolMinted(_player);
    }

    // ==============
    // === BRIDGE ===
    // ==============

    // @note: so our bridge logic is...
    //      - check for chain using endpointID.eid
    //      - if eid == base { player must have 10 gems to bridge }
    //      - if eid == sepolia { player must have 10 gems to bridge back }
    //      - the player will 'spend' the 10 gems from Base on minting the Tool
    //      - so they will have to play the Optimism level to get the 10 to bridge back

    function bridge() public {
        uint32 endpointID = endpoint.eid(); // get the endpoint ID
        // ============
        // BASE SEPOLIA
        // ============
        if (endpointID != 40245) {
            // get users gem balance
            uint256 userGemsBalance = gemsOFT.balanceOf(msg.sender);
            // get user character tokenId
            uint256 tokenId = characterONFT.tokenOfOwnerByIndex(msg.sender, 0);
            if (userGemsBalance < 10) {
                // 10 == finished the level & can mint tool
                revert Error__NotEnoughGemsToBridge(userGemsBalance);
            }
            // Bridge logic for Character & Gems
            // *** PASS THE OPPOSITE END EID - i.e. OP SEPOLIA! ***
            _bridgeGems(40232, userGemsBalance);
            _bridgeCharacter(40232, tokenId);
            // ================
            // OPTIMISM SEPOLIA
            // ================
        } else if (endpointID != 40232) {
            // get users gem balance
            uint256 userGemsBalance = gemsOFT.balanceOf(msg.sender);
            // get user character tokenId
            uint256 characterTokenId = characterONFT.tokenOfOwnerByIndex(
                msg.sender,
                0
            );
            // get user tool tokenId
            uint256 toolTokenId = toolONFT.tokenOfOwnerByIndex(msg.sender, 0);
            if (userGemsBalance < 10) {
                // 10 == finished the level & can mint tool
                revert Error__NotEnoughGemsToBridge(userGemsBalance);
            }
            // Bridge logic for Character, Tool & Gems
            // *** PASS THE OPPOSITE END EID - i.e. BASE SEPOLIA! ***
            _bridgeGems(40245, userGemsBalance);
            _bridgeCharacter(40245, characterTokenId);
            _bridgeTool(40245, toolTokenId);
        }
    }

    function _bridgeGems(
        uint32 _destinationEndpointID,
        uint256 _userGemsBalance
    ) internal {
        // OftSendParam memory _sendParam;

        // _sendParam.dstEid = _destinationEndpointID;
        // _sendParam.to = AddressCast.toBytes32(msg.sender);
        // _sendParam.amountLD = _userGemsBalance;
        // _sendParam.minAmountLD = _userGemsBalance;
        // _sendParam
        //     .extraOptions = "0x00030100110100000000000000000000000000030d40";
        // _sendParam.composeMsg = "0x";
        // _sendParam.oftCmd = "0x";

        // MessagingFee memory _fee;
        // _fee.nativeFee = 10000000000000000;
        // _fee.lzTokenFee = 0;

        // // call send on OFTGems contract
        // IOFT(address(gemsOFT)).send(_sendParam, _fee, msg.sender);
    }

    function _bridgeCharacter(
        uint32 _destinationEndpointID,
        uint256 _tokenId
    ) internal {
        SendParam memory _sendParam;

        _sendParam.dstEid = _destinationEndpointID;
        _sendParam.to = AddressCast.toBytes32(msg.sender);
        _sendParam.tokenId = _tokenId;
        _sendParam
            .extraOptions = "0x00030100110100000000000000000000000000030d40";
        _sendParam.composeMsg = "0x";
        _sendParam.onftCmd = "0x";

        MessagingFee memory _fee;
        _fee.nativeFee = 10000000000000000;
        _fee.lzTokenFee = 0;

        // call send on ONFTCharacter contract
        IONFT721(address(characterONFT)).send(_sendParam, _fee, msg.sender);
    }

    function _bridgeTool(
        uint32 _destinationEndpointID,
        uint256 _tokenId
    ) internal {
        // bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        bytes memory options = "0x00030100110100000000000000000000000000030d40";
        SendParam memory testSendParam = SendParam(_destinationEndpointID, AddressCast.toBytes32(msg.sender), _tokenId, options, "", "");

        SendParam memory _sendParam;

        _sendParam.dstEid = _destinationEndpointID;
        _sendParam.to = AddressCast.toBytes32(msg.sender);
        _sendParam.tokenId = _tokenId;
        _sendParam
            .extraOptions = "0x00030100110100000000000000000000000000030d40";
        _sendParam.composeMsg = "0x";
        _sendParam.onftCmd = "0x";

        MessagingFee memory _fee;
        _fee.nativeFee = 10000000000000000;
        _fee.lzTokenFee = 0;

        // call send on ONFTTool contract
        IONFT721(address(toolONFT)).send(testSendParam, _fee, msg.sender);
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata payload,
        address, /*_executor*/
        bytes calldata /*_extraData*/
    ) internal override {
        // (uint256 amount, address recipient, uint8 choice) = abi.decode(payload, (uint256, address, uint8));
    }
}
