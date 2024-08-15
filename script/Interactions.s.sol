// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , , , address account) = helperConfig
            .activeNetworkConfig();
        return createSubscription(vrfCoordinator, account);
    }

    function createSubscription(
        address vrfCoordinator,
        address account
    ) public returns (uint256) {
        console.log("Creating subscription on ChainId: ", block.chainid);
        vm.startBroadcast(account);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your sub Id is: ", subId);
        console.log("Please update subscriptionId in HelperConfig.s.sol");
        return subId;
    }

    function run() external returns (uint256) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    // if FUND_AMOUNT too low(such as 3 ether) in local test, will lead to `VRFCoordinatorV2_5Mock::InsufficientBalance()` when run `RaffleTest.t::testFulfillRandomWordsPicksWinnerResetsAndSendsMoney`
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint256 subId,
            ,
            address link,
            address account
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator, subId, link, account);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subId,
        address link,
        address account
    ) public {
        console.log("Funding subscription: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On chainID: ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast(account);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(account);
            LinkToken(link).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint256 subId,
            ,
            ,
            address account
        ) = helperConfig.activeNetworkConfig();

        //如果InteractionsTest/testCanAddConsumerInteractions使用的anvil链，则subId需要
        //创建并资助订阅获取，这里修改代码
        // @24.8.14 好像在anvil链运行创建资助订阅已经在deployRaffle中处理，这里直接注释掉就行
        //
        // if (block.chainid == 31337) {
        //     CreateSubscription createSubscription = new CreateSubscription();
        //     subId = createSubscription.createSubscription(
        //         vrfCoordinator,
        //         deployerKey
        //     );

        //     vm.startBroadcast();
        //     LinkToken link = new LinkToken();
        //     vm.stopBroadcast();

        //     FundSubscription fundSubscription = new FundSubscription();
        //     fundSubscription.fundSubscription(
        //         vrfCoordinator,
        //         subId,
        //         address(link),
        //         deployerKey
        //     );
        // }

        addConsumer(vrfCoordinator, subId, raffle, account);
    }

    function addConsumer(
        address vrfCoordinator,
        uint256 subId,
        address raffle,
        address account
    ) public {
        console.log("Adding Consumer contract: ", raffle);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On chainID: ", block.chainid);
        console.log("SubID:", subId);
        vm.startBroadcast(account);
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, raffle);
        vm.stopBroadcast();
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(raffle);
    }
}
