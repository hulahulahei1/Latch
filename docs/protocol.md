# Protocol

LATCH defines a proof-gated execution loop.

```text
Round → Capsule → Burn Credential → Agent Solve → ZK Proof → Onchain Unlock
```

---

## 1. Round creation

A round is created with a capsule commitment.

The capsule may be stored offchain, but its hash is recorded onchain.

```text
roundId
capsuleHash
programHash
difficulty
target
verifier
startTime
endTime
```

The answer is not stored anywhere onchain.

---

## 2. Capsule generation

A capsule is generated from a round seed.

Recommended seed source:

```text
roundSeed = VRF output + previousRoundHash + roundId + chainId
```

The generator should be deterministic and open source.

```text
roundSeed → capsule generator → Maze-Time Capsule
```

The protocol should not rely on secret题目. It should rely on fresh randomness and proof soundness.

---

## 3. BurnBox entry

The agent SDK computes a deterministic BurnBox address:

```text
burnBox = CREATE2(factory, user, roundId, token, salt)
```

The user sends project token to the BurnBox address.

Anyone can call `finalizeBurn`.

Finalization:

```text
1. deploy BurnBox if needed
2. read token balance
3. burn / dead-transfer the token
4. mint ProofNFT
5. mark burn credential for round
```

The BurnBox must not be an EOA. It must not have a private key.

---

## 4. Proof NFT

The ProofNFT records:

```text
roundId
user
burnedAmount
hintLevel
createdAt
used
```

The NFT should be non-transferable in early versions to prevent credential markets from dominating the game.

---

## 5. Agent solving

The agent receives:

```text
public capsule
hint capsule based on ProofNFT level
proof parameters
round metadata
```

The agent solves offchain.

For Maze-Time Capsules, solving means:

```text
1. identify a valid route through randomized maze gates
2. derive a routeKey
3. run sequential Time-Lock / Memory-Lock steps
4. find a final state satisfying the target
5. generate a ZK proof binding user, round, nftId, nullifier, and rewardAddress
```

---

## 6. Proof verification

A proof submission includes:

```text
roundId
nftId
rewardAddress
nullifier
publicInputs
proofBytes
```

The verifier must bind:

```text
roundId
capsuleHash
programHash
target
user
nftId
rewardAddress
nullifier
```

If proof verification succeeds, `RoundManager` marks the nullifier used and unlocks the configured action.

---

## 7. Action unlock

LATCH does not require a single economic model.

A proof can unlock:

- a delayed reward;
- a treasury action;
- a scheduled buyback;
- a credential;
- an access right;
- a settlement event.

The scaffold includes `ActionLocker` as the generic delayed-action primitive.

---

## 8. Minimal invariant set

The protocol should enforce:

```text
No proof without a round.
No proof without a valid ProofNFT.
No reused nullifier.
No mismatched capsule hash.
No mutable verifier after round start, unless explicitly governed.
No direct answer reveal required.
No keeper-only execution path.
```
