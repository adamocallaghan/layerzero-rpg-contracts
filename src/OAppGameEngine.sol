// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {IONFT721, MessagingFee, MessagingReceipt, SendParam} from "@layerzerolabs/onft-evm/contracts/onft721/interfaces/IONFT721.sol";
import {IOFT} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IOFTGems, IONFTCharacter, IONFTTool, OftSendParam, OftMessagingFee} from "./interfaces/GameInterfaces.sol";
import {AddressCast} from "../utils/AddressCast.sol";
// import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

interface ILayerZeroEndpointV2 {
    function eid() external view returns (uint32);
}

contract OAppGameEngine is OApp {
    // ====================
    // === STORAGE VARS ===
    // ====================

    IONFTCharacter public characterONFT;
    IONFTTool public toolONFT;
    IOFTGems public gemsOFT;
    ILayerZeroEndpointV2 public lzEndpoint;

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

    event BaseToOpHitOk();
    event OpToBaseHitOk();
    event CharacterBridged();
    event ToolBridged();

    event BridgeGemsHit();

    event HitFunctionOk();

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
        lzEndpoint = ILayerZeroEndpointV2(_endpoint);
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
        uint32 endpointID = lzEndpoint.eid(); // get the endpoint ID
        if (endpointID != 40232) {
            revert Error__ToolCannotBeMintedOnThisChain(); // tool can only be minted on Op Sepolia!
        }
        toolONFT.mintToolToPlayer(_player);
        emit ToolMinted(_player);
    }

    // ==============
    // === BRIDGE ===
    // ==============

    function testBridgeCharacter(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable {
        IONFT721(address(characterONFT)).send{value: msg.value}(
            _sendParam,
            _fee,
            _refundAddress
        );
    }

    function testBridgeTool(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable {
        IONFT721(address(toolONFT)).send{value: msg.value}(
            _sendParam,
            _fee,
            _refundAddress
        );
    }

    // @note: the following is working
    // however, Gems OFT needs to be deployed with an overridden send() function
    // so we can pass the user's address (default send func uses msg.sender)
    function testBridgeGems(
        OftSendParam calldata _sendParam,
        OftMessagingFee calldata _fee,
        address _refundAddress
    ) external payable {
        IOFTGems(address(gemsOFT)).send{value: msg.value}(
            _sendParam,
            _fee,
            _refundAddress
        );
    }

    // @note: so our bridge logic is...
    //      - check for chain using endpointID.eid
    //      - if eid == base { player must have 10 gems to bridge }
    //      - if eid == sepolia { player must have 10 gems to bridge back }
    //      - the player will 'spend' the 10 gems from Base on minting the Tool
    //      - so they will have to play the Optimism level to get the 10 to bridge back

    function bridge(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) public payable {
        uint32 endpointID = lzEndpoint.eid(); // get the endpoint ID
        // ============
        // BASE SEPOLIA
        // ============
        if (endpointID == 40245) {
            // get users gem balance
            uint256 userGemsBalance = gemsOFT.balanceOf(msg.sender);
            // getting the user's character tokenId will have to be handled on the frontend for now
            // ...using ONFTEnumerable caused contract too large errors, will figure it out again
            if (userGemsBalance < 10) {
                // 10 == finished the level & can mint tool
                revert Error__NotEnoughGemsToBridge(userGemsBalance);
            }
            // _bridgeGems(40232, userGemsBalance);
            _bridgeCharacter(_sendParam, _fee, _refundAddress);
            emit HitFunctionOk();
            // ================
            // OPTIMISM SEPOLIA
            // ================
        } else if (endpointID == 40232) {
            // get users gem balance
            uint256 userGemsBalance = gemsOFT.balanceOf(msg.sender);
            // getting the user's character tokenId will have to be handled on the frontend for now
            // ...using ONFTEnumerable caused contract too large errors, will figure it out again
            if (userGemsBalance < 10) {
                // 10 == finished the level & can mint tool
                revert Error__NotEnoughGemsToBridge(userGemsBalance);
            }

            // _bridgeGems(40245, userGemsBalance);
            _bridgeCharacter(_sendParam, _fee, _refundAddress);
            // _bridgeTool(40245, toolTokenId);
        }
    }

    // @note: add in the gems logic, etc., and make this the main function
    // @todo: we want to pass in our Tool tokenId and change the _sendParam to _sendCharacterParam & _sendToolParam
    // otherwise the character & tool need to be the same tokenId, which is absurd!
    function bridgeMultiWithTokenIds(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress,
        uint256 _toolTokenId
        // uint256 _userGemsBalance
    ) public payable {
        uint32 endpointID = lzEndpoint.eid(); // get the endpoint ID
        // ============
        // BASE SEPOLIA
        // ============
        if (endpointID == 40245) {
            // _bridgeGems(40232, userGemsBalance);
            _bridgeCharacter(_sendParam, _fee, _refundAddress);
            _bridgeTool(_sendParam, _fee, _refundAddress, _toolTokenId);
            // _bridgeGems(_sendParam, _fee, _refundAddress, _userGemsBalance);
            emit BaseToOpHitOk();
            // ================
            // OPTIMISM SEPOLIA
            // ================
        } else if (endpointID == 40232) {
            // _bridgeGems(40245, userGemsBalance);
            _bridgeCharacter(_sendParam, _fee, _refundAddress);
            _bridgeTool(_sendParam, _fee, _refundAddress, _toolTokenId);
            emit OpToBaseHitOk();
        }
    }

    function _bridgeGems(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress,
        uint256 _userGemsBalance
    ) internal {
        // call send on OFTGems contract
        // OftSendParam memory _oftSendParam;
        // _oftSendParam.dstEid = _sendParam.dstEid;
        // _oftSendParam.to = _sendParam.to;
        // _oftSendParam.amountLD = _userGemsBalance;
        // _oftSendParam.minAmountLD = _userGemsBalance;
        // _oftSendParam.extraOptions = "0x00030100110100000000000000000000000000030d40"; // @NOTE: changed on 29th May at 5:18pm, redploy and check if this was the issue, it was set as "0x" but our tokens need options passed
        // _oftSendParam.composeMsg = "0x";
        // _oftSendParam.oftCmd = "0x";

        // OftMessagingFee memory _oftMessagingFee;
        // _oftMessagingFee.lzTokenFee = _fee.lzTokenFee;
        // _oftMessagingFee.nativeFee = _fee.nativeFee;

        // gemsOFT.send(_oftSendParam, _oftMessagingFee, _refundAddress);
        emit BridgeGemsHit();
    }

    function _bridgeCharacter(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) internal {
        // call send on ONFTCharacter contract
        IONFT721(address(characterONFT)).send{value: _fee.nativeFee}(
            _sendParam,
            _fee,
            _refundAddress
        );

        emit CharacterBridged();
    }

    function bridgeToolDirect(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) public payable {
        // _bridgeTool(_sendParam, _fee, _refundAddress, _toolTokenId);
    }

    function _bridgeTool(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress,
        uint256 _toolTokenId
    ) internal {
        SendParam memory _toolSendParam = _sendParam;
        _toolSendParam.tokenId = _toolTokenId;
        // call send on ONFTTool contract
        IONFT721(address(toolONFT)).send{value: _fee.nativeFee}(
            _toolSendParam,
            _fee,
            _refundAddress
        );

        emit ToolBridged();
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata payload,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        // (uint256 amount, address recipient, uint8 choice) = abi.decode(payload, (uint256, address, uint8));
    }

    function setGemsOftContract(address _gemsOFT) public {
        gemsOFT = IOFTGems(_gemsOFT);
    }
}
