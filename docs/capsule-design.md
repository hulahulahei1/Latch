# Maze-Time Capsule Design

A LATCH capsule is a computation challenge designed for AI-assisted solving and onchain proof verification.

It is not a human riddle.
It is not a hidden answer stored by the project.
It is a randomized lock.

---

## Capsule definition

A capsule is defined by:

```json
{
  "roundId": 18,
  "type": "maze-time",
  "capsuleHash": "0x...",
  "programHash": "0x...",
  "difficulty": 4,
  "maze": {
    "gates": 32,
    "branches": 12,
    "deadEnds": 18,
    "routeEntropyBits": 28
  },
  "timeLock": {
    "steps": 1200000,
    "function": "sequential_hash_memory_mix"
  },
  "memoryLock": {
    "memorySizeMb": 256,
    "lanes": 4
  },
  "target": {
    "leadingZeroBits": 28
  }
}
```

---

## Why Maze + Time-Lock

A pure hash target becomes a CUDA race.

A pure maze becomes a code puzzle that can be solved once and copied.

A pure time-lock makes AI irrelevant.

Maze-Time combines them:

```text
AI finds the path.
The path derives the key.
The key starts the time-lock.
The time-lock produces the final state.
ZK proves the route and state are valid.
```

---

## Difficulty knobs

Difficulty is not subjective. It is derived from parameters.

| Parameter | Purpose |
|---|---|
| `routeEntropyBits` | estimated maze search space |
| `timeLock.steps` | minimum sequential work |
| `memorySizeMb` | memory pressure to reduce simple GPU advantage |
| `leadingZeroBits` | final target probability |
| `hintReductionBits` | how much a hint lowers search space |

Example target bands:

```text
Level 1: route 14 bits, 100k steps, 64MB memory, 20 target bits
Level 2: route 20 bits, 300k steps, 128MB memory, 24 target bits
Level 3: route 26 bits, 800k steps, 256MB memory, 28 target bits
Level 4: route 32 bits, 1.5M steps, 512MB memory, 32 target bits
Level 5: route 38 bits, 3M steps, 1GB memory, 36 target bits
```

---

## Hint design

Hints should reduce search space, not reveal answers.

Examples:

```text
Hint L1: eliminate 25% of dead gates
Hint L2: reveal two required memory lanes
Hint L3: reduce route entropy by 8 bits
Hint L4: reveal partial gate ordering but not route key
```

A good hint helps an AI reason better. It does not replace solving.

---

## Open-source safety

The generator can be open source because each round depends on fresh seed material.

Open source reveals:

```text
how locks are made
```

It does not reveal:

```text
which route opens the current lock
```

Security must come from randomness, proof soundness, and nullifier binding — not from hiding code.
