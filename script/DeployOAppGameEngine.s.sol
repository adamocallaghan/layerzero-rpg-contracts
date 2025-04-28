// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {OAppGameEngine} from "../src/OAppGameEngine.sol";
import {AddressCast} from "../utils/AddressCast.sol";

contract DeployOAppGameEngine is Script {
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

        // ONFT character & tool addresses for OAPP constructor
        address ONFT_CHARACTER_ADDRESS = vm.envAddress("ONFT_CHARACTER_ADDRESS");
        address ONFT_TOOL_ADDRESS = vm.envAddress("ONFT_TOOL_ADDRESS");
        address OFT_GEMS_ADDRESS = vm.envAddress("OFT_GEMS_ADDRESS");
        
        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("#######################################");
        console2.log("########## Deploying to Base ##########");
        console2.log("#######################################");

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // deploy OAPP
        OAppGameEngine baseOapp = new OAppGameEngine{salt: "rabbit"}(
            vm.envAddress(BASE_LZ_ENDPOINT), // lzEndpoint
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS), // owner
            ONFT_CHARACTER_ADDRESS,
            ONFT_TOOL_ADDRESS,
            OFT_GEMS_ADDRESS
        );
        console2.log("Our OAPP Game Engine contract on Base is deployed to: ", address(baseOapp));

        vm.stopBroadcast();

        // ============================
        // === OPTIMISM DEPLOYMENTS ===
        // ============================

        console2.log("###########################################");
        console2.log("########## Deploying to Optimism ##########");
        console2.log("###########################################");

        vm.createSelectFork("optimism");

        vm.startBroadcast(deployerPrivateKey);

        // deploy OAPP
        OAppGameEngine optimismOapp = new OAppGameEngine{salt: "rabbit"}(
            vm.envAddress(OPTIMISM_LZ_ENDPOINT), // lzEndpoint
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS), // owner
            ONFT_CHARACTER_ADDRESS,
            ONFT_TOOL_ADDRESS,
            OFT_GEMS_ADDRESS
        );
        console2.log("Our OAPP Game Engine contract on Optimism is deployed to: ", address(optimismOapp));

        vm.stopBroadcast();
    }
}
