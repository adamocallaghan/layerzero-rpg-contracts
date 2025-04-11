// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {ONFTCharacter} from "../src/ONFTCharacter.sol";

interface IMyOAppRead {
    function setPeer(uint32, bytes32) external;
}

contract SetPeers is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // Oapp Bytes32 format Address (Same address all chains)
        // bytes32 OAPP_BYTES32 = 0x000000000000000000000000DC2586e87a02866C385bd42260AC943A8848E69B;
        bytes32 OAPP_BYTES32 = vm.envBytes32("OAPP_BYTES32");
        // Oapp Address (same address all chains)
        address OAPP_ADDRESS = vm.envAddress("OAPP_ADDRESS");
        // address DEPLOYER_PUBLIC_ADDRESS = vm.envAddress("DEPLOYER_PUBLIC_ADDRESS");

        // === BASE ===
        uint256 baseLzEndIdUint = vm.envUint("BASE_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 BASE_SEPOLIA_LZ_ENDPOINT_ID = uint32(baseLzEndIdUint);

        // === BASE LZ-ENDPOINT ===
        address baseLzEndpoint = vm.envAddress("BASE_SEPOLIA_LZ_ENDPOINT");
        // uint32 BASE_SEPOLIA_LZ_ENDPOINT = uint32(baseLzEndpoint);

        // === ARBIRTUM ===
        uint256 arbLzEndIdUint = vm.envUint("ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID = uint32(arbLzEndIdUint);

        uint256 baseToArbChannelId = vm.envUint("BASE_TO_ARB_CHANNEL_ID");
        uint32 BASE_TO_ARB_CHANNEL_ID = uint32(baseToArbChannelId);

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("########################################");
        console2.log("########## Setting Base Peers ##########");
        console2.log("########################################");
        console2.log("                                        ");
        console2.log("Setting Base Oapp Peer at: ", OAPP_ADDRESS);

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // OAPP Wire-Ups
        IMyOAppRead(OAPP_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        vm.stopBroadcast();

        // ========================
        // === ARBITRUM WIRE-UP ===
        // ========================

        console2.log("############################################");
        console2.log("########## Setting Arbitrum Peers ##########");
        console2.log("############################################");
        console2.log("                                            ");
        console2.log("Setting Arbirtum Oapp Peer at: ", OAPP_ADDRESS);

        vm.createSelectFork("arbitrum");

        vm.startBroadcast(deployerPrivateKey);

        // OAPP Wire-Ups
        IMyOAppRead(OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        vm.stopBroadcast();

        // ========================
        // === SET READ LIBRARY ===
        // ========================

        // Initialize the endpoint contract
        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(baseLzEndpoint);
        // address _sendLib = 0x54320b901FDe49Ba98de821Ccf374BA4358a8bf6; // arb -> base
        address _readLib = 0x29270F0CFC54432181C853Cd25E2Fb60A68E03f2; // base -> arb

        // address _baseSendLib = 0xC1868e054425D378095A003EcbA3823a5D0135C9;
        // address _baseReceiveLib = 0x12523de19dc41c91F7d2093E0CFbB76b17012C8d;

        vm.createSelectFork("base");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // // Set the send library *as the READLIB*
        endpoint.setSendLibrary(OAPP_ADDRESS, BASE_TO_ARB_CHANNEL_ID, _readLib);
        console2.log("Send library set to Read Lib.");

        // // Set the receive library *as the READLIB*
        endpoint.setReceiveLibrary(OAPP_ADDRESS, BASE_TO_ARB_CHANNEL_ID, _readLib, 0);
        console2.log("Receive library set to Read Lib.");

        vm.stopBroadcast();

        // LzReadCounter contractAddress;   *** NOT REQUIRED: user OAPP_ADDRESS
        // uint32 remoteEid;                *** NOT REQUIRED: use ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID
        // address sendLibraryAddress;      *** NOT REQUIRED: use _readLib
        // address signer;                  *** NOT REQUIRED: user DEPLOYER_ADDRESS (CHECK THIS?)

        // =======================
        // === SET SEND CONFIG ===
        // =======================

        // uint64 confirmations = 15;
        // uint8 requiredDVNCount = 1;
        // uint8 optionalDVNCount = 0;
        // uint8 optionalDVNThreshold = 0;
        address[] memory _requiredDVNs = new address[](1);
        address[] memory _optionalDVNs = new address[](0);

        _requiredDVNs[0] = 0xbf6FF58f60606EdB2F190769B951D825BCb214E2;

        UlnConfig memory ulnConfig;
        ulnConfig.confirmations = 50;
        ulnConfig.requiredDVNCount = 1;
        ulnConfig.optionalDVNCount = 0;
        ulnConfig.optionalDVNThreshold = 0;
        ulnConfig.requiredDVNs = _requiredDVNs;
        ulnConfig.optionalDVNs = _optionalDVNs;

        uint32 maxMessageSize = 100000;
        address executor = 0x8A3D588D9f6AC041476b094f97FF94ec30169d3D;

        ExecutorConfig memory executorConfig;

        executorConfig.maxMessageSize = maxMessageSize;
        executorConfig.executor = executor;

        uint32 EXECUTOR_CONFIG_TYPE = 1;
        uint32 ULN_CONFIG_TYPE = 2;

        SetConfigParam[] memory setSendConfigParams = new SetConfigParam[](2);

        setSendConfigParams[0] = SetConfigParam({
            eid: BASE_TO_ARB_CHANNEL_ID,
            configType: EXECUTOR_CONFIG_TYPE,
            config: abi.encode(executorConfig)
        });

        setSendConfigParams[1] =
            SetConfigParam({eid: BASE_TO_ARB_CHANNEL_ID, configType: ULN_CONFIG_TYPE, config: abi.encode(ulnConfig)});

        console2.log("#########################################");
        console2.log("########## Setting SEND Config ##########");
        console2.log("#########################################");
        console2.log("                                            ");
        console2.log("Setting Send Config, setConfig() on: ", OAPP_ADDRESS);
        console2.log("Read Lib: ", _readLib);
        console2.log("ulnConfig.confirmations: ", ulnConfig.confirmations);
        console2.log("ulnConfig.requiredDVNCount: ", ulnConfig.requiredDVNCount);
        console2.log("ulnConfig.optionalDVNCount: ", ulnConfig.optionalDVNCount);
        console2.log("ulnConfig.optionalDVNThreshold: ", ulnConfig.optionalDVNThreshold);
        console2.log("ulnConfig.requiredDVNs: ", ulnConfig.requiredDVNs[0]);
        // console2.log("ulnConfig.optionalDVNs: ", ulnConfig.optionalDVNs[0]);
        console2.log("executorConfig.maxMessageSize: ", executorConfig.maxMessageSize);
        console2.log("executorConfig.executor: ", executorConfig.executor);

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        endpoint.setConfig(address(OAPP_ADDRESS), _readLib, setSendConfigParams);

        vm.stopBroadcast();

        // ==========================
        // === SET RECEIVE CONFIG ===
        // ==========================

        uint32 RECEIVE_CONFIG_TYPE = 2;

        SetConfigParam[] memory setReceiveConfigParams = new SetConfigParam[](1);

        setReceiveConfigParams[0] = SetConfigParam({
            eid: BASE_TO_ARB_CHANNEL_ID,
            configType: RECEIVE_CONFIG_TYPE,
            config: abi.encode(ulnConfig)
        });

        vm.startBroadcast(deployerPrivateKey);

        endpoint.setConfig(address(OAPP_ADDRESS), _readLib, setReceiveConfigParams);

        vm.stopBroadcast();

        // ========================
        // === SET READ CHANNEL ===
        // ========================

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Set the channelId
        OAppRead(OAPP_ADDRESS).setReadChannel(BASE_TO_ARB_CHANNEL_ID, true);

        vm.stopBroadcast();
    }
}
