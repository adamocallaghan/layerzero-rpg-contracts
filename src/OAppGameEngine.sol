// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { OApp, Origin, MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { IONFT721 } from "@layerzerolabs/onft-evm/contracts/onft721/interfaces/IONFT721.sol";
import { IOFT } from "lib/devtools/packages/oft-evm/contracts/interfaces/IOFT.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Vault is OApp {
    // ====================
    // === STORAGE VARS ===
    // ====================

    IOFT public gemsOFT;
    IONFT721 public characterONFT;
    IONFT721 public toolONFT;

    enum Level {
        Village,
        Woods,
        Mountain,
        Crypts
    }

    // ==============
    // === ERRORS ===
    // ==============

    error Error__NotEnoughTokensToMint();

    // ==============
    // === EVENTS ===
    // ==============

    event CharacterMinted(address, uint256);
    event ToolMinted(address, uint256);

    // ===================
    // === CONSTRUCTOR ===
    // ===================

    constructor(address _endpoint, address _delegate, address _characterContract, address _toolContract, address _gemsContract) OApp(_endpoint, _delegate) {
        characterONFT = IONFT721(_characterContract);
        toolONFT = IONFT721(_toolContract);
        gemsOFT = IOFT(_gemsContract);
    }

    // ================================
    // === SUPPLY ETH AS COLLATERAL ===
    // ================================

    function supply() public payable {
        // update user's balance
        userCollateral[msg.sender] += msg.value;

        emit EthCollateralSupplied(msg.sender, msg.value);
    }

    // ====================
    // === WITHDRAW ETH ===
    // ====================

    function withdraw() public payable {
        if (userCollateral[msg.sender] >= msg.value) {
            // update user's balance
            uint256 withdrawalAmount = msg.value;
            userCollateral[msg.sender] -= msg.value;

            // transfer ETH back to user
            msg.sender.call{value: withdrawalAmount}("");

            emit EthCollateralWithdrawn(msg.sender, withdrawalAmount);
        } else {
            revert Error__NoCollateralSupplied();
        }
    }

    // ===============
    // === LZ SEND ===
    // ===============

    function send(uint32 _dstEid, uint256 _amount, address _recipient, uint8 _choice, bytes calldata _options)
        external
        payable
        returns (MessagingReceipt memory receipt)
    {
        if (userCollateral[msg.sender] > 0) {
            bytes memory _payload = abi.encode(_amount, _recipient, _choice);
            receipt = _lzSend(_dstEid, _payload, _options, MessagingFee(msg.value, 0), payable(msg.sender));
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
        address, /*_executor*/
        bytes calldata /*_extraData*/
    ) internal override {
        (uint256 amount, address recipient, uint8 choice) = abi.decode(payload, (uint256, address, uint8));

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