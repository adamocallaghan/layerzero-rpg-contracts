// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {ONFTCharacter} from "../src/ONFTCharacter.sol";
import {AddressCast} from "../utils/AddressCast.sol";

interface IONFT {
    function setPeer(uint32, bytes32) external;
}

contract DeployONFTCharacter is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        // deployer
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // base lz endpoint + id
        string memory BASE_LZ_ENDPOINT = "BASE_SEPOLIA_LZ_ENDPOINT";
        uint256 baseLzEndIdUint = vm.envUint("BASE_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 BASE_SEPOLIA_LZ_ENDPOINT_ID = uint32(baseLzEndIdUint);

        // op lz endpoint + id
        string memory OPTIMISM_LZ_ENDPOINT = "OPTIMISM_SEPOLIA_LZ_ENDPOINT";
        uint256 opLzEndIdUint = vm.envUint("OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID = uint32(opLzEndIdUint);

        // Oapp Bytes32 format Address (same address all chains)
        bytes32 ONFT_BYTES32 = vm.envBytes32("ONFT_BYTES32");
        // Oapp Address (same address all chains)
        address ONFT_ADDRESS = vm.envAddress("ONFT_ADDRESS");
        
        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("#######################################");
        console2.log("########## Deploying to Base ##########");
        console2.log("#######################################");

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // deploy ONFT
        ONFTCharacter baseONFT = new ONFTCharacter{salt: "zelda1"}(
            "ZeroTheHero",
            "ZHRO",
            vm.envAddress(BASE_LZ_ENDPOINT), // lzEndpoint
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS) // owner
        );
        console2.log("Our ONFT Character contract on Base is deployed to: ", address(baseONFT));

        vm.stopBroadcast();

        // ============================
        // === OPTIMISM DEPLOYMENTS ===
        // ============================

        console2.log("###########################################");
        console2.log("########## Deploying to Optimism ##########");
        console2.log("###########################################");

        vm.createSelectFork("optimism");

        vm.startBroadcast(deployerPrivateKey);

        // deploy ONFT
        ONFTCharacter optimismONFT = new ONFTCharacter{salt: "zelda1"}(
            "ZeroTheHero",
            "ZHRO",
            vm.envAddress(OPTIMISM_LZ_ENDPOINT), // lzEndpoint
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS) // owner
        );
        console2.log("Our ONFT Character contract on Optimism is deployed to: ", address(optimismONFT));

        vm.stopBroadcast();

        // =============================================================
        // === ADDRESS CAST LIB: 
        // === - Get left-padded Bytes32 version of our ONFT Address
        // === - Used in our LayerZero 'wire-ups' in next steps
        // === - Only need to do it once as our ONFTs have the same address on both chains
        // =============================================================

        bytes32 ONFT_BYTES32 = AddressCast.toBytes32(address(baseONFT));

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("########################################");
        console2.log("########## Setting Base Peers ##########");
        console2.log("########################################");
        console2.log("                                        ");
        console2.log("Setting Base ONFT Peer at: ", baseONFT);

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // ONFT Wire-Ups
        IONFT(baseONFT).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, ONFT_BYTES32);

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
        IONFT(optimismONFT).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, ONFT_BYTES32);

        vm.stopBroadcast();
    }
}
