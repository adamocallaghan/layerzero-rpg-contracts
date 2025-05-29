// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {AddressCast} from "../utils/AddressCast.sol";
import {stdJson} from "forge-std/StdJson.sol";

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
        address ownerOfCharacterIndexZero = IONFT(ONFT_CHARACTER_ADDRESS).ownerOf(0);
        if(ownerOfCharacterIndexZero == DEPLOYER_PUBLIC_ADDRESS) {
            console2.log("YES - OUR DEPLOYER ACCOUNT OWNS THE CHARACTER AT INDEX ZERO");
        }

        // Tool balance/owner checks...
        address ownerOfToolIndexZero = IONFT(ONFT_TOOL_ADDRESS).ownerOf(0);
        if(ownerOfToolIndexZero == DEPLOYER_PUBLIC_ADDRESS) {
            console2.log("YES - OUR DEPLOYER ACCOUNT OWNS THE TOOL AT INDEX ZERO");
        }

        // Gems balance/owner checks...
        uint256 gemsBalance = IOFT(OFT_GEMS_ADDRESS).balanceOf(DEPLOYER_PUBLIC_ADDRESS);
        if(gemsBalance == 1000000e18) {
            console2.log("YES - OUR DEPLOYER ACCOUNT HAS 1000000e18 GEMS");
        }

        // vm.stopBroadcast();
    }

    function bytesToAddress(
        bytes memory bys
    ) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 32))
        }
    }
}
