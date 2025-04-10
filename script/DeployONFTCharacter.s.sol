// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {ONFTCharacter} from "../src/ONFTCharacter.sol";

contract DeployToBase is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory BASE_LZ_ENDPOINT = "BASE_SEPOLIA_LZ_ENDPOINT";
        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("#######################################");
        console2.log("########## Deploying to Base ##########");
        console2.log("#######################################");

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // deploy ONFT
        ONFTCharacter baseONFT = new ONFTCharacter{salt: "werewolf"}(
            vm.envAddress(BASE_LZ_ENDPOINT), // lzEndpoint
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS) // owner
        );
        console2.log("Our ONF Character contract is deployed to: ", address(baseONFT));

        vm.stopBroadcast();
    }
}
