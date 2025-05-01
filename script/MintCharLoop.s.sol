// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {AddressCast} from "../utils/AddressCast.sol";

interface IONFT {
    function setPeer(uint32, bytes32) external;
    function ownerOf(uint256) external returns (address);
    function mintCharacterToPlayer(address) external;
}

contract MintCharLoop is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        // deployer
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address DEPLOYER_PUBLIC_ADDRESS = vm.envAddress("DEPLOYER_PUBLIC_ADDRESS");

        // our deployed game asset addresses (from our env file)
        address ONFT_CHARACTER_ADDRESS = vm.envAddress("ONFT_CHARACTER_ADDRESS");

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // Mint 20 ONFTs to deployer...
        for (uint256 i = 0; i < 23; i++) {
            IONFT(ONFT_CHARACTER_ADDRESS).mintCharacterToPlayer(DEPLOYER_PUBLIC_ADDRESS);
        }
        
        vm.stopBroadcast();
    }
}
