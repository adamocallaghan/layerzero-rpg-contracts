// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {OAppGameEngine} from "../src/OAppGameEngine.sol";
import {AddressCast} from "../utils/AddressCast.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract DeployOAppGameEngine is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        // deployer
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory  DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // base lz endpoint + id
        string memory  BASE_LZ_ENDPOINT = "BASE_SEPOLIA_LZ_ENDPOINT";

        // op lz endpoint + id
        string memory OPTIMISM_LZ_ENDPOINT = "OPTIMISM_SEPOLIA_LZ_ENDPOINT";

        string memory SALT = vm.envString("SALT");
        bytes32 SALT32 = AddressCast.stringToBytes32(SALT);
        console2.log("SALT is: ", SALT);

        console2.log("********************************************");
        console2.log("********************************************");
        console2.log("********************************************");
        console2.log(DEPLOYER_PUBLIC_ADDRESS);
        console2.log(BASE_LZ_ENDPOINT);
        console2.log(OPTIMISM_LZ_ENDPOINT);
        console2.log(SALT);
        console2.log("********************************************");
        console2.log("********************************************");
        console2.log("********************************************");

        // ONFT character, tool & OFT gems addresses for OAPP constructor
        // address ONFT_CHARACTER_ADDRESS = vm.envAddress("ONFT_CHARACTER_ADDRESS");
        // address ONFT_TOOL_ADDRESS = vm.envAddress("ONFT_TOOL_ADDRESS");
        // address OFT_GEMS_ADDRESS = vm.envAddress("OFT_GEMS_ADDRESS");

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
        
        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("#######################################");
        console2.log("########## Deploying to Base ##########");
        console2.log("#######################################");

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // deploy OAPP
        OAppGameEngine baseOapp = new OAppGameEngine{salt: SALT32}(
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
        OAppGameEngine optimismOapp = new OAppGameEngine{salt: SALT32}(
            vm.envAddress(OPTIMISM_LZ_ENDPOINT), // lzEndpoint
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS), // owner
            ONFT_CHARACTER_ADDRESS,
            ONFT_TOOL_ADDRESS,
            OFT_GEMS_ADDRESS
        );
        console2.log("Our OAPP Game Engine contract on Optimism is deployed to: ", address(optimismOapp));

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
