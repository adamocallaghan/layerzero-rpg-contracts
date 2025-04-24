// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {AddressCast} from "../utils/AddressCast.sol";

interface IONFT {
    function setPeer(uint32, bytes32) external;
}

contract SetPeers is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        // deployer
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        // base lz endpoint + id
        uint256 baseLzEndIdUint = vm.envUint("BASE_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 BASE_SEPOLIA_LZ_ENDPOINT_ID = uint32(baseLzEndIdUint);

        // op lz endpoint + id
        uint256 opLzEndIdUint = vm.envUint("OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID = uint32(opLzEndIdUint);

        address ONFT_ADDRESS = vm.envAddress("ONFT_ADDRESS");

        // =============================================================
        // === ADDRESS CAST LIB: 
        // === - Get left-padded Bytes32 version of our ONFT Address
        // === - Used in our LayerZero 'wire-ups' in next steps
        // === - Only need to do it once as our ONFTs have the same address on both chains
        // =============================================================

        bytes32 ONFT_BYTES32 = AddressCast.toBytes32(ONFT_ADDRESS);
        console2.logBytes32(ONFT_BYTES32);

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("########################################");
        console2.log("########## Setting Base Peers ##########");
        console2.log("########################################");
        console2.log("                                        ");
        console2.log("Setting Base ONFT Peer at: ", ONFT_ADDRESS);

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // ONFT Wire-Ups
        IONFT(ONFT_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, ONFT_BYTES32);

        vm.stopBroadcast();

        // ========================
        // === OPTIMISM WIRE-UP ===
        // ========================

        console2.log("############################################");
        console2.log("########## Setting Optimism Peers ##########");
        console2.log("############################################");
        console2.log("                                        ");
        console2.log("Setting Optimism ONFT Peer at: ", ONFT_ADDRESS);

        vm.createSelectFork("optimism");

        vm.startBroadcast(deployerPrivateKey);

        // ONFT Wire-Ups
        IONFT(ONFT_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, ONFT_BYTES32);

        vm.stopBroadcast();
    }
}
