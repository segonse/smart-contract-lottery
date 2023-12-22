// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title A sample Raffle COntract
 * @author Segonse
 * @notice This contarct is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle {
    error Raffle__notEnoughETHSent();

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() external payable {
        // 如果这个函数不会再合约内部进行操作的话设置为external而不是public会更加节省gas
        // require(msg.value >= i_entranceFee);  //revert比require更加节省gas
        if (msg.value < i_entranceFee) {
            revert Raffle__notEnoughETHSent();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() public {}

    /** Getter Function */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
