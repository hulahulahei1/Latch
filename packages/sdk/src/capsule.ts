import { keccak256, stringToBytes, toBytes } from "viem";
import type { Hex, MazeTimeCapsule } from "./types.js";

export function normalizeCapsule(capsule: MazeTimeCapsule): string {
  return JSON.stringify(capsule, Object.keys(capsule).sort());
}

export function hashCapsule(capsule: MazeTimeCapsule): Hex {
  return keccak256(stringToBytes(JSON.stringify(capsule)));
}

export function assertCapsuleHash(capsule: MazeTimeCapsule, expected: Hex): void {
  const actual = hashCapsule(capsule);
  if (actual.toLowerCase() !== expected.toLowerCase()) {
    throw new Error(`Capsule hash mismatch: expected ${expected}, got ${actual}`);
  }
}

export function estimateWork(capsule: MazeTimeCapsule): string {
  const route = capsule.maze.routeEntropyBits;
  const target = capsule.target.leadingZeroBits;
  const steps = capsule.timeLock.steps;
  const memory = capsule.memoryLock.memorySizeMb;
  return `route≈2^${route}, target≈2^${target}, timelock=${steps} steps, memory=${memory}MB`;
}

export function deriveAgentPrompt(capsule: MazeTimeCapsule): string {
  return [
    `LATCH Round #${capsule.roundId}`,
    `Type: ${capsule.type}`,
    `Difficulty: ${capsule.difficulty}`,
    `Work: ${estimateWork(capsule)}`,
    "Goal: find a private route and final state that can be proven with the configured ZK verifier.",
    "Do not reveal private solution material in public logs."
  ].join("\n");
}
