// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            //在这里分开本地测试和测试网络链的运行逻辑,测试网络在chainlink网站页面手动创建订阅并赞助
            //分叉测试并不会实际添加consumer,在没有--broadcast选项的情况下
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinator,
                deployerKey
            );

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinator,
                subscriptionId,
                link,
                deployerKey
            );
        }

        vm.startBroadcast(deployerKey); //这里不使用deployerKey的话，testPerformUpkeepRevertsIfCheckUpkeepIsFalse返回错误Raffle__UpkeepNotNeeded合约会有0.04ether的余额，暂未弄清楚原理
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer( //需要保证前面创建订阅和赞助的user和这里添加顾客一致，所以都需要传递deployerKey
            vrfCoordinator,
            subscriptionId,
            address(raffle),
            deployerKey
        );
        return (raffle, helperConfig);
    }
}
