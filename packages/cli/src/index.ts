#!/usr/bin/env node
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { deriveAgentPrompt, estimateWork, formatBurnInstruction, type MazeTimeCapsule } from "@latch/sdk";

const [, , command, ...args] = process.argv;

function help() {
  console.log(`LATCH — Verifiable execution for AI agents on Base

Usage:
  latch help
  latch round <capsule.json>
  latch prompt <capsule.json>
  latch burnbox <address>

Commands:
  round     Print capsule summary
  prompt    Print an agent-oriented solving prompt
  burnbox   Format a BurnBox instruction for a computed address
`);
}

function readCapsule(file: string): MazeTimeCapsule {
  const path = resolve(process.cwd(), file);
  return JSON.parse(readFileSync(path, "utf8")) as MazeTimeCapsule;
}

if (!command || command === "help" || command === "--help") {
  help();
  process.exit(0);
}

if (command === "round") {
  const file = args[0];
  if (!file) throw new Error("Missing capsule file");
  const capsule = readCapsule(file);
  console.log(`Round #${capsule.roundId}`);
  console.log(`Type: ${capsule.type}`);
  console.log(`Difficulty: ${capsule.difficulty}`);
  console.log(`Capsule: ${capsule.capsuleHash}`);
  console.log(`Program: ${capsule.programHash}`);
  console.log(`Work: ${estimateWork(capsule)}`);
  process.exit(0);
}

if (command === "prompt") {
  const file = args[0];
  if (!file) throw new Error("Missing capsule file");
  const capsule = readCapsule(file);
  console.log(deriveAgentPrompt(capsule));
  process.exit(0);
}

if (command === "burnbox") {
  const address = args[0] as `0x${string}` | undefined;
  if (!address) throw new Error("Missing BurnBox address");
  console.log(formatBurnInstruction(address));
  process.exit(0);
}

throw new Error(`Unknown command: ${command}`);
