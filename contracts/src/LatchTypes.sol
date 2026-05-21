// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library LatchTypes {
    enum RoundStatus {
        None,
        Open,
        Solved,
        Closed
    }

    struct Round {
        bytes32 capsuleHash;
        bytes32 programHash;
        bytes32 target;
        uint64 startTime;
        uint64 endTime;
        uint32 difficulty;
        address verifier;
        RoundStatus status;
    }

    struct ProofSubmission {
        uint256 roundId;
        uint256 proofNftId;
        address solver;
        address rewardAddress;
        bytes32 nullifier;
        bytes publicInputs;
        bytes proof;
    }

    struct BurnCredential {
        uint256 roundId;
        uint256 burnedAmount;
        uint32 hintLevel;
        uint64 mintedAt;
        bool used;
    }
}
