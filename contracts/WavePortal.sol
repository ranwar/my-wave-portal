// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint totalWaves;
    uint private seed;

    event NewWave(address indexed from, uint timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint timestamp;
    }

    Wave[] waves;

    mapping(address => uint) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
    }

    function wave(string memory _message) public {
        // 15min wait
        require(lastWavedAt[msg.sender] + 30 seconds < block.timestamp, "Wait 30secs");
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s is waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));
        emit NewWave(msg.sender, block.timestamp, _message);

        // generate prandom 100
        uint randomNumber = (block.difficulty + block.timestamp + seed) % 100;
        console.log("prandom generated: %s", randomNumber);
        seed = randomNumber;

        if (randomNumber < 50) {
            console.log("%s won!", msg.sender);

            uint prizeAmount = 0.0001 ether;
            require(prizeAmount <= address(this).balance, "Trying to withdraw more money than the contract has.");

            (bool success,) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
    }

    function getAllWaves() view public returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() view public returns (uint) {
        console.log("We have %d total waves", totalWaves);
        return totalWaves;
    }
}
