//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

struct User {
        address id;
        uint256 guess;
        uint256 amountBet;
        bool hasGuessed;
    }