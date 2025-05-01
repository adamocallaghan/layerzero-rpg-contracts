// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {AddressCast} from "../utils/AddressCast.sol";

interface IONFT {
    function setPeer(uint32, bytes32) external;
    function ownerOf(uint256) external returns (address);
}

interface IOFT {
    function setPeer(uint32, bytes32) external;
    function balanceOf(address) external returns (uint256);
}

contract SanityCheck is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        // deployer
        // uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address DEPLOYER_PUBLIC_ADDRESS = vm.envAddress("DEPLOYER_PUBLIC_ADDRESS");

        // our deployed game asset addresses (from our env file)
        address ONFT_CHARACTER_ADDRESS = vm.envAddress("ONFT_CHARACTER_ADDRESS");
        address ONFT_TOOL_ADDRESS = vm.envAddress("ONFT_TOOL_ADDRESS");
        address OFT_GEMS_ADDRESS = vm.envAddress("OFT_GEMS_ADDRESS");

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("##############################################################");
        console2.log("########## Checking that we have our ONFTs and OFTs ##########");
        console2.log("##############################################################");
        console2.log("                                        ");

        vm.createSelectFork("base");

        // vm.startBroadcast(deployerPrivateKey);

        // Character balance/owner checks...
        address ownerOfCharacterIndexZero = IONFT(ONFT_CHARACTER_ADDRESS).ownerOf(11);
        if(ownerOfCharacterIndexZero == DEPLOYER_PUBLIC_ADDRESS) {
            console2.log("YES - OUR DEPLOYER ACCOUNT OWNS THE CHARACTER AT INDEX 11");
        }

        // Tool balance/owner checks...
        address ownerOfToolIndexZero = IONFT(ONFT_TOOL_ADDRESS).ownerOf(22);
        if(ownerOfToolIndexZero == DEPLOYER_PUBLIC_ADDRESS) {
            console2.log("YES - OUR DEPLOYER ACCOUNT OWNS THE TOOL AT INDEX 22");
        }

        // Gems balance/owner checks...
        uint256 gemsBalance = IOFT(OFT_GEMS_ADDRESS).balanceOf(DEPLOYER_PUBLIC_ADDRESS);
        if(gemsBalance == 10) {
            console2.log("YES - OUR DEPLOYER ACCOUNT HAS 10 GEMS");
        }

        // vm.stopBroadcast();
    }
}
