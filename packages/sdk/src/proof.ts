import { encodeAbiParameters, keccak256, parseAbiParameters } from "viem";
import type { Hex, ProofPayload } from "./types.js";

export interface ProofBindingInput {
  chainId: bigint;
  roundManager: Hex;
  roundId: bigint;
  capsuleHash: Hex;
  programHash: Hex;
  target: Hex;
  solver: Hex;
  proofNftId: bigint;
  rewardAddress: Hex;
  nullifier: Hex;
  publicInputsHash: Hex;
}

export function buildProofBinding(input: ProofBindingInput): Hex {
  return keccak256(
    encodeAbiParameters(
      parseAbiParameters(
        "uint256 chainId, address roundManager, uint256 roundId, bytes32 capsuleHash, bytes32 programHash, bytes32 target, address solver, uint256 proofNftId, address rewardAddress, bytes32 nullifier, bytes32 publicInputsHash"
      ),
      [
        input.chainId,
        input.roundManager,
        input.roundId,
        input.capsuleHash,
        input.programHash,
        input.target,
        input.solver,
        input.proofNftId,
        input.rewardAddress,
        input.nullifier,
        input.publicInputsHash
      ]
    )
  );
}

export function describeProofPayload(payload: ProofPayload): string {
  return [
    `roundId=${payload.roundId}`,
    `proofNftId=${payload.proofNftId}`,
    `solver=${payload.solver}`,
    `rewardAddress=${payload.rewardAddress}`,
    `nullifier=${payload.nullifier}`,
    `publicInputs=${payload.publicInputs.length} hex chars`,
    `proof=${payload.proof.length} hex chars`
  ].join("\n");
}
