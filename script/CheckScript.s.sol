// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract CheckScript is Script {
    function run() external view {
        string memory root = vm.projectRoot();

        // ===============================================
        // Get ONFTCharacter Address from broadcast folder
        // ===============================================
        string memory characterPath = string.concat(
            root,
            "/broadcast/multi/DeployONFTCharacter.s.sol-latest/run.json"
        );
        string memory characterJson = vm.readFile(characterPath);
        bytes memory characterContractName = stdJson.parseRaw(
            characterJson,
            ".deployments[0].transactions[0].contractName"
        );
        bytes memory characterContractAddress = stdJson.parseRaw(
            characterJson,
            ".deployments[0].transactions[0].contractAddress"
        );

        console.log("==========================================");
        console.log("===", string(characterContractName), "===");
        console.logAddress(bytesToAddress(characterContractAddress));
        console.logBytes(characterContractAddress);
        console.log("==========================================");

        // ===============================================
        // Get ONFTTool Address from broadcast folder
        // ===============================================
        string memory toolPath = string.concat(
            root,
            "/broadcast/multi/DeployONFTTool.s.sol-latest/run.json"
        );
        string memory toolJson = vm.readFile(toolPath);
        bytes memory toolContractName = stdJson.parseRaw(
            toolJson,
            ".deployments[0].transactions[0].contractName"
        );
        bytes memory toolContractAddress = stdJson.parseRaw(
            toolJson,
            ".deployments[0].transactions[0].contractAddress"
        );

        console.log("===", string(toolContractName), "===");
        console.logAddress(bytesToAddress(toolContractAddress));
        console.logBytes(toolContractAddress);
        console.log("==========================================");

        // ===============================================
        // Get OFTGems Address from broadcast folder
        // ===============================================
        string memory gemsPath = string.concat(
            root,
            "/broadcast/multi/DeployONFTTool.s.sol-latest/run.json"
        );
        string memory gemsJson = vm.readFile(gemsPath);
        bytes memory gemsContractName = stdJson.parseRaw(
            gemsJson,
            ".deployments[0].transactions[0].contractName"
        );
        bytes memory gemsContractAddress = stdJson.parseRaw(
            gemsJson,
            ".deployments[0].transactions[0].contractAddress"
        );

        console.log("===", string(gemsContractName), "===");
        console.logAddress(bytesToAddress(gemsContractAddress));
        console.logBytes(gemsContractAddress);
        console.log("==========================================");
        
    }

    function bytesToAddress(
        bytes memory bys
    ) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 32))
        }
    }
}