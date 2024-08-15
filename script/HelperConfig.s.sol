// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
// import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        // uint256 deployerKey;
        address account;
    }

    uint256 public constant ANVIL_PRIVITE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 74011984632010530725190690538934249576295114270375682340520379188539003939385,
                callbackGasLimit: 500000,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                // deployerKey: vm.envUint("SEPOLIA_PRIVATE_KEY")
                account: 0x663a162f0a90FA4A7Cb45678dE17932b8704C990
            });
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }
        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;
        int256 weiPerUnitLink = 4e15;

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(
                baseFee,
                gasPriceLink,
                weiPerUnitLink
            );
        LinkToken link = new LinkToken();
        vm.stopBroadcast();

        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: address(vrfCoordinatorV2_5Mock),
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // doesn't matter, can any
                subscriptionId: 0,
                callbackGasLimit: 500000, // 500000 gas
                link: address(link),
                account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
            });
    }
}
