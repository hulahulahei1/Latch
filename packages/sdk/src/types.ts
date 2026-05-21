export type Hex = `0x${string}`;

export interface RoundMetadata {
  roundId: number;
  capsuleHash: Hex;
  programHash: Hex;
  target: Hex;
  difficulty: number;
  verifier: Hex;
  startTime: number;
  endTime: number;
}

export interface MazeTimeCapsule {
  schema: "latch.capsule.v1";
  roundId: number;
  type: "maze-time";
  chainId: number;
  capsuleHash: Hex;
  programHash: Hex;
  difficulty: number;
  maze: {
    gates: number;
    branches: number;
    deadEnds: number;
    routeEntropyBits: number;
  };
  timeLock: {
    steps: number;
    function: string;
  };
  memoryLock: {
    memorySizeMb: number;
    lanes: number;
  };
  target: {
    leadingZeroBits: number;
    digest: Hex;
  };
  hints?: Array<{
    level: number;
    reductionBits: number;
    note: string;
  }>;
}

export interface BurnBoxRequest {
  factory: Hex;
  token: Hex;
  proofNFT: Hex;
  user: Hex;
  roundId: bigint;
  userSalt: Hex;
  hintUnit: bigint;
}

export interface ProofPayload {
  roundId: bigint;
  proofNftId: bigint;
  solver: Hex;
  rewardAddress: Hex;
  nullifier: Hex;
  publicInputs: Hex;
  proof: Hex;
}
