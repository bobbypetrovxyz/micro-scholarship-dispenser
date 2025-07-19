// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {ScholarshipFactory} from "../src/ScholarshipFactory.sol";
import {ScholarshipDispenser} from "../src/ScholarshipDispenser.sol";

contract DeployScript is Script {
    function run() external {
        address adminAddress = vm.envAddress("ADMIN_ADDRESS");
        address directorAddress = vm.envAddress("DIRECTOR_ADDRESS");

        vm.startBroadcast();

        ScholarshipDispenser implementation = new ScholarshipDispenser();
        console.log(
            "ScholarshipDispenser implementation deployed at:",
            address(implementation)
        );

        ScholarshipFactory factory = new ScholarshipFactory(
            address(implementation),
            adminAddress,
            directorAddress
        );
        console.log("ScholarshipFactory deployed at:", address(factory));
        console.log("Admin address:", adminAddress);

        vm.stopBroadcast();
    }
}

// forge script script/deploy.s.sol:DeployScript --broadcast --verify -vvvv --rpc-url sepolia --private-key fb13f686d3f2a0d11f40a94e4204a6d8f00806b9f187b0bbb7729a3f1592e948 --etherscan-api-key "${ETHERSCAN_API_KEY}"
//
