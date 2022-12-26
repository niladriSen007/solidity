// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.8
pragma solidity ^0.8.8;

contract Lottery {
    address public manager;
    address payable[] public participants;
    uint public totalFunding;
    bool public winnerSelected;

    constructor()  {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value == 0.002 ether, "Incorrect entry fee");
        participants.push(payable(msg.sender));
        totalFunding += msg.value;
    }

    function selectWinner() public onlyManager {
        require(participants.length >= 2, "Contest must have at least 3 participants");
        require(!winnerSelected, "Winner has already been selected");

        uint index = random() % participants.length;
        address payable winner = participants[index];
        (bool sent, bytes memory data) = winner.call{value: totalFunding}("");
        require(sent, "Failed to send Ether");

        winnerSelected = true;
    }

    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can perform this action");
        _;
    }
}
