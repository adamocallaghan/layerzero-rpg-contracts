// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {IONFT721} from "@layerzerolabs/onft-evm/contracts/onft721/interfaces/IONFT721.sol";
import {IOFT} from "lib/devtools/packages/oft-evm/contracts/interfaces/IOFT.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IOFTGems, IONFTCharacter, IONFTTool} from "./interfaces/GameInterfaces.sol";

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

    // ==============
    // === EVENTS ===
    // ==============

    event CharacterMinted(address, uint256);
    event ToolMinted(address, uint256);
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
    ) OApp(_endpoint, _delegate) {
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
        uint32 endpointID = ILayerZeroEndpointV2(_endpoint).eid(); // get the endpoint ID
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
        uint32 endpointID = ILayerZeroEndpointV2(_endpoint).eid(); // get the endpoint ID
        // ============
        // BASE SEPOLIA
        // ============
        if (endpointID != 40245) {
            // get users gem balance
            uint256 userGemsBalance = gemsOFT.balanceOf(_player);
            if (userGemsBalance < 10) {
                // 10 == finished the level & can mint tool
                revert Error__NotEnoughGemsToBridge(userGemsBalance);
            }
            // Bridge logic for Character & Gems
        // ================
        // OPTIMISM SEPOLIA
        // ================
        } else if (endpointID != 40232) {
            // get users gem balance
            uint256 userGemsBalance = gemsOFT.balanceOf(_player);
            if (userGemsBalance < 10) {
                // 10 == finished the level & can mint tool
                revert Error__NotEnoughGemsToBridge(userGemsBalance);
            }
            // Bridge logic for Character, Tool & Gems
        }
    }

    // ===============
    // === LZ SEND ===
    // ===============

    function send(
        uint32 _dstEid,
        uint256 _amount,
        address _recipient,
        uint8 _choice,
        bytes calldata _options
    ) external payable returns (MessagingReceipt memory receipt) {
        if (userCollateral[msg.sender] > 0) {
            bytes memory _payload = abi.encode(_amount, _recipient, _choice);
            receipt = _lzSend(
                _dstEid,
                _payload,
                _options,
                MessagingFee(msg.value, 0),
                payable(msg.sender)
            );
        } else {
            revert Error__NoCollateralSupplied();
        }
    }

    // ==================
    // === LZ RECEIVE ===
    // ==================

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata payload,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        (uint256 amount, address recipient, uint8 choice) = abi.decode(
            payload,
            (uint256, address, uint8)
        );

        // update tokensMinted on OAPP
        tokensMinted[recipient] += amount;

        // send composed call to the token contract
        endpoint.sendCompose(token, _guid, 0, payload);
    }

    // =========================
    // === SETTERS & GETTERS ===
    // =========================

    function setToken(address _token) external onlyOwner {
        token = _token;
    }
}
