// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {AddressCast} from "../utils/AddressCast.sol";
import {stdJson} from "forge-std/StdJson.sol";

interface IONFT {
    function setPeer(uint32, bytes32) external;
}

interface IOFT {
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

        string memory root = vm.projectRoot();

        // ===============================================
        // Get ONFTCharacter Address from broadcast folder
        // ===============================================
        string memory characterPath = string.concat(
            root,
            "/broadcast/multi/DeployONFTCharacter.s.sol-latest/run.json"
        );
        string memory characterJson = vm.readFile(characterPath);
        bytes memory characterContractAddress = stdJson.parseRaw(
            characterJson,
            ".deployments[0].transactions[0].contractAddress"
        );
        address ONFT_CHARACTER_ADDRESS = bytesToAddress(characterContractAddress);
        console2.log(ONFT_CHARACTER_ADDRESS);

        // ===============================================
        // Get ONFTTool Address from broadcast folder
        // ===============================================
        string memory toolPath = string.concat(
            root,
            "/broadcast/multi/DeployONFTTool.s.sol-latest/run.json"
        );
        string memory toolJson = vm.readFile(toolPath);
        bytes memory toolContractAddress = stdJson.parseRaw(
            toolJson,
            ".deployments[0].transactions[0].contractAddress"
        );

        address ONFT_TOOL_ADDRESS = bytesToAddress(toolContractAddress);
        console2.log(ONFT_TOOL_ADDRESS);

        // ===============================================
        // Get OFTGems Address from broadcast folder
        // ===============================================
        string memory gemsPath = string.concat(
            root,
            "/broadcast/multi/DeployOFTGems.s.sol-latest/run.json"
        );
        string memory gemsJson = vm.readFile(gemsPath);
        bytes memory gemsContractAddress = stdJson.parseRaw(
            gemsJson,
            ".deployments[0].transactions[0].contractAddress"
        );

        address OFT_GEMS_ADDRESS = bytesToAddress(gemsContractAddress);
        console2.log(OFT_GEMS_ADDRESS);

        // =============================================================
        // === ADDRESS CAST LIB: 
        // === - Get left-padded Bytes32 version of our ONFT Address
        // === - Used in our LayerZero 'wire-ups' in next steps
        // === - Only need to do it once as our ONFTs have the same address on both chains
        // =============================================================

        bytes32 ONFT_CHARACTER_BYTES32 = AddressCast.toBytes32(ONFT_CHARACTER_ADDRESS);
        console2.logBytes32(ONFT_CHARACTER_BYTES32);

        bytes32 ONFT_TOOL_BYTES32 = AddressCast.toBytes32(ONFT_TOOL_ADDRESS);
        console2.logBytes32(ONFT_TOOL_BYTES32);

        bytes32 OFT_GEMS_BYTES32 = AddressCast.toBytes32(OFT_GEMS_ADDRESS);
        console2.logBytes32(OFT_GEMS_BYTES32);

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("########################################");
        console2.log("########## Setting Base Peers ##########");
        console2.log("########################################");
        console2.log("                                        ");
        console2.log("Setting Base ONFT *Character* Peer at: ", ONFT_CHARACTER_ADDRESS);
        console2.log("Setting Base ONFT *Tool* Peer at: ", ONFT_TOOL_ADDRESS);
        console2.log("Setting Base OFT *Gems* Peer at: ", OFT_GEMS_ADDRESS);

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // ONFT Wire-Ups
        IONFT(ONFT_CHARACTER_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, ONFT_CHARACTER_BYTES32);
        IONFT(ONFT_TOOL_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, ONFT_TOOL_BYTES32);
        // OFT Wire-Up
        IOFT(OFT_GEMS_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, OFT_GEMS_BYTES32);

        vm.stopBroadcast();

        // ========================
        // === OPTIMISM WIRE-UP ===
        // ========================

        console2.log("############################################");
        console2.log("########## Setting Optimism Peers ##########");
        console2.log("############################################");
        console2.log("                                        ");
        console2.log("Setting Optimism ONFT Peer at: ", ONFT_CHARACTER_ADDRESS);
        console2.log("Setting Optimism ONFT *Tool* Peer at: ", ONFT_TOOL_ADDRESS);
        console2.log("Setting Optimism OFT *Gems* Peer at: ", OFT_GEMS_ADDRESS);

        vm.createSelectFork("optimism");

        vm.startBroadcast(deployerPrivateKey);

        // ONFT Wire-Ups
        IONFT(ONFT_CHARACTER_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, ONFT_CHARACTER_BYTES32);
        IONFT(ONFT_TOOL_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, ONFT_TOOL_BYTES32);
        // OFT Wire-Up
        IOFT(OFT_GEMS_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OFT_GEMS_BYTES32);

        vm.stopBroadcast();
    }

    function bytesToAddress(
        bytes memory bys
    ) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 32))
        }
    }
}
