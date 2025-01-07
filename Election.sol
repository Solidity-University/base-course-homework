// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Election {

    string[] public electors;
    //["Vasya","Taska","Basta","Papsha"]

    uint256 public maxVotes;

    uint256 public electionEndTime;

    mapping(address => bool) public userVotes;

    mapping(uint256 => uint256) public numberOfVotes;

    constructor(string[] memory _electors) {
        electors = _electors;
    }

    function vote(uint256 _number) public {
        require(userVotes[msg.sender]==false, "Your address can't vote");
        require(_number < electors.length, "Elector does not exist");
        userVotes[msg.sender] = true;
        numberOfVotes[_number] += 1;
    }

    //add maxVotes functionality
    //add contract owner
    //contract owner can't vote
    //add stop voting functionality
    //only owner can't stop voting
    //HARD
    //add electionTime functionality using block.timestamp










}