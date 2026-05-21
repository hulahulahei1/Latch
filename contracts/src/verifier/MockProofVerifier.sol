// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IProofVerifier} from "./IProofVerifier.sol";

/// @notice Mock verifier for local tests only.
/// @dev Accepts proof == keccak256(publicInputs) encoded as bytes32.
contract MockProofVerifier is IProofVerifier {
    function verify(bytes calldata proof, bytes calldata publicInputs) external pure returns (bool) {
        if (proof.length != 32) return false;
        bytes32 expected = keccak256(publicInputs);
        bytes32 got;
        assembly {
            got := calldataload(proof.offset)
        }
        return got == expected;
    }
}
