// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {ONFTCharacter} from "../src/ONFTCharacter.sol";
import {AddressCast} from "../utils/AddressCast.sol";

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

        // op lz endpoint + id
        string memory OPTIMISM_LZ_ENDPOINT = "OPTIMISM_SEPOLIA_LZ_ENDPOINT";

        string memory ONFT_CHARACTER_NAME = "ONFT_CHARACTER_NAME";
        string memory ONFT_CHARACTER_SYMBOL = "ONFT_CHARACTER_SYMBOL";
        
        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("#######################################");
        console2.log("########## Deploying to Base ##########");
        console2.log("#######################################");

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // deploy ONFT
        ONFTCharacter baseONFT = new ONFTCharacter{salt: "beluga"}(
            ONFT_CHARACTER_NAME,
            ONFT_CHARACTER_SYMBOL,
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
        ONFTCharacter optimismONFT = new ONFTCharacter{salt: "beluga"}(
            ONFT_CHARACTER_NAME,
            ONFT_CHARACTER_SYMBOL,
            vm.envAddress(OPTIMISM_LZ_ENDPOINT), // lzEndpoint
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS) // owner
        );
        console2.log("Our ONFT Character contract on Optimism is deployed to: ", address(optimismONFT));

        vm.stopBroadcast();
    }
}
