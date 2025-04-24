// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2} from "lib/forge-std/src/Script.sol";
import {AddressCast} from "../utils/AddressCast.sol";

contract TestAddressCast is Script {
    function run() external {

        // ONFT Address...
        address ONFT_ADDRESS = vm.envAddress("ONFT_ADDRESS");
        console2.log("ONFT_ADDRESS: ", ONFT_ADDRESS);

        // Hardcoded ONFT Bytes32 Address from ENV file...
        // bytes32 ONFT_BYTES32 = vm.envBytes32("ONFT_BYTES32");
        // console2.log("ONFT_BYTES32: ");
        // console2.logBytes32(ONFT_BYTES32);

        // ONFT Bytes32 Address created using AddressCast lib...
        bytes32 ONFT_BYTES32_CAST = AddressCast.toBytes32(ONFT_ADDRESS);
        console2.log("ONFT_BYTES32_CAST: ");
        console2.logBytes32(ONFT_BYTES32_CAST);

        // They should match...
        // if(ONFT_BYTES32 == ONFT_BYTES32_CAST) {
        //     console2.log("*** Hardcoded Bytes32 Address and Casted Bytes32 Address match! ***");
        // }

    }
}
