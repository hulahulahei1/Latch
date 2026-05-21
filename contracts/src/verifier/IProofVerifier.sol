// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IProofVerifier {
    /// @notice Verifies a proof against public inputs.
    /// @dev Production implementations must bind roundId, capsuleHash, programHash,
    /// target, solver, proofNftId, rewardAddress, and nullifier into publicInputs.
    function verify(bytes calldata proof, bytes calldata publicInputs) external view returns (bool);
}
