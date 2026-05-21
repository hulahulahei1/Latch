// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OwnableLite} from "./OwnableLite.sol";
import {LatchTypes} from "./LatchTypes.sol";
import {ProofNFT} from "./ProofNFT.sol";
import {IProofVerifier} from "./verifier/IProofVerifier.sol";

/// @notice Coordinates LATCH rounds and proof submissions.
contract RoundManager is OwnableLite {
    ProofNFT public immutable proofNFT;

    uint256 public nextRoundId = 1;
    mapping(uint256 => LatchTypes.Round) public rounds;
    mapping(bytes32 => bool) public usedNullifiers;

    event RoundCreated(
        uint256 indexed roundId,
        bytes32 capsuleHash,
        bytes32 programHash,
        bytes32 target,
        uint32 difficulty,
        address verifier,
        uint64 startTime,
        uint64 endTime
    );
    event RoundClosed(uint256 indexed roundId);
    event ProofAccepted(uint256 indexed roundId, address indexed solver, uint256 indexed proofNftId, bytes32 nullifier, address rewardAddress);

    error InvalidRound();
    error RoundNotOpen();
    error RoundExpired();
    error InvalidVerifier();
    error InvalidProofNFT();
    error NotSolverCredential();
    error NullifierUsed();
    error InvalidProof();

    constructor(address initialOwner, address proofNFT_) OwnableLite(initialOwner) {
        proofNFT = ProofNFT(proofNFT_);
    }

    function createRound(
        bytes32 capsuleHash,
        bytes32 programHash,
        bytes32 target,
        uint32 difficulty,
        address verifier,
        uint64 startTime,
        uint64 endTime
    ) external onlyOwner returns (uint256 roundId) {
        if (verifier == address(0)) revert InvalidVerifier();
        if (endTime <= startTime || endTime <= block.timestamp) revert InvalidRound();

        roundId = nextRoundId++;
        rounds[roundId] = LatchTypes.Round({
            capsuleHash: capsuleHash,
            programHash: programHash,
            target: target,
            startTime: startTime,
            endTime: endTime,
            difficulty: difficulty,
            verifier: verifier,
            status: LatchTypes.RoundStatus.Open
        });

        emit RoundCreated(roundId, capsuleHash, programHash, target, difficulty, verifier, startTime, endTime);
    }

    function closeRound(uint256 roundId) external onlyOwner {
        LatchTypes.Round storage round = rounds[roundId];
        if (round.status == LatchTypes.RoundStatus.None) revert InvalidRound();
        round.status = LatchTypes.RoundStatus.Closed;
        emit RoundClosed(roundId);
    }

    function submitProof(LatchTypes.ProofSubmission calldata submission) external {
        LatchTypes.Round storage round = rounds[submission.roundId];
        if (round.status != LatchTypes.RoundStatus.Open) revert RoundNotOpen();
        if (block.timestamp < round.startTime || block.timestamp > round.endTime) revert RoundExpired();
        if (usedNullifiers[submission.nullifier]) revert NullifierUsed();

        address credentialOwner = proofNFT.ownerOf(submission.proofNftId);
        if (credentialOwner != submission.solver) revert NotSolverCredential();

        LatchTypes.BurnCredential memory credential = proofNFT.credentialOf(submission.proofNftId);
        if (credential.roundId != submission.roundId || credential.used) revert InvalidProofNFT();

        bytes32 binding = keccak256(
            abi.encode(
                block.chainid,
                address(this),
                submission.roundId,
                round.capsuleHash,
                round.programHash,
                round.target,
                submission.solver,
                submission.proofNftId,
                submission.rewardAddress,
                submission.nullifier,
                keccak256(submission.publicInputs)
            )
        );

        bytes memory verifierInputs = abi.encode(binding, submission.publicInputs);
        bool ok = IProofVerifier(round.verifier).verify(submission.proof, verifierInputs);
        if (!ok) revert InvalidProof();

        usedNullifiers[submission.nullifier] = true;
        proofNFT.markUsed(submission.proofNftId);
        round.status = LatchTypes.RoundStatus.Solved;

        emit ProofAccepted(submission.roundId, submission.solver, submission.proofNftId, submission.nullifier, submission.rewardAddress);
    }

    function getRound(uint256 roundId) external view returns (LatchTypes.Round memory) {
        return rounds[roundId];
    }
}
