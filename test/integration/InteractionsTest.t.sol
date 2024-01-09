// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {AddConsumer} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    Raffle raffle;
    AddConsumer addConsumer;

    function setUp() external {
        // addConsumer = new AddConsumer();
    }

    function testCanAddConsumerInteractions() public {
        //此测试只有在broadcast目录中有有效部署在sepolia链上raffle才能用
        //或者开启anvil链并部署raffle进行测试(需要创建并资助订阅,在交互sol文件addConsumerUsingConfig中修改)
        //sepolia链上不管同一地址有没有添加为consumer，均可通过测试（但是测试无法--broadcast,也就无法真实在链上添加consumer）
        // addConsumer.run();
    }

    //把interactions的几个函数(chainlink自动化部署)一起测试？
}
