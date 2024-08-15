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
            uint256 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            // uint256 deployerKey
            // 24.8.15 现在此参数由私钥变为了账户地址
            address account
        ) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            //在这里分开本地测试和测试网络链的运行逻辑,测试网络在chainlink网站页面手动创建订阅并赞助
            //分叉测试并不会实际添加consumer,在没有--broadcast选项的情况下
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinator,
                account
            );

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinator,
                subscriptionId,
                link,
                account
            );
        }

        vm.startBroadcast(account); //这里不使用deployerKey的话，testPerformUpkeepRevertsIfCheckUpkeepIsFalse返回错误Raffle__UpkeepNotNeeded合约会有0.04ether的余额，暂未弄清楚原理
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        // 24.8.15 sepolia链addConsumer报错：custom error 1f6a65b6: ，导致raffle合约无法验证，使用时这块暂注释 maybe
        // network error?
        // 第二天测试addconsumer 报错为InvalidSubscription(), 在chainlink网站中通过metamask交互，发现现有订阅
        // 还是和之前的vrf-v2地址0x8103B...64625交互！！
        // 24.8.15 目前除了创建订阅返回subid和实际不一致，其余VRF一套和etherscan验证合约通过脚本部署均完成
        // 自动化选择costom logic, 中间提示vrf余额3link不足，等待的交易要花费10多link，添加了后又只花费了0.35link，实现了自动化
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer( //需要保证前面创建订阅和赞助的user和这里添加顾客一致，所以都需要传递deployerKey
            vrfCoordinator,
            subscriptionId,
            address(raffle),
            account
        );
        return (raffle, helperConfig);
    }
}
