//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

import "./GuessIs.sol";

struct User {
        address id;
        uint256 guess;
        bool hasGuessed;
        GuessIs guessIs;
        uint256 amountBet;
        uint256 winningPercentage;  
    }