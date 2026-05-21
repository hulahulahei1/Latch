# ZK Layer

LATCH uses ZK proofs to verify that an agent solved a capsule without revealing the private route, nonce, or final solution.

This folder defines the intended proof boundary. It does not include a production circuit yet.

---

## Statement to prove

A valid proof should prove:

```text
I know private inputs:
  route
  nonce
  memoryWitness
  finalState

Such that:
  route is valid for capsuleHash/programHash
  route derives routeKey
  routeKey initializes the Time-Lock computation
  Time-Lock / Memory-Lock reaches finalState
  hash(finalState) satisfies target
  proof binds solver, roundId, proofNftId, rewardAddress, and nullifier
```

---

## Public inputs

Recommended public inputs:

```text
chainId
roundManager
roundId
capsuleHash
programHash
target
solver
proofNftId
rewardAddress
nullifier
```

---

## Private inputs

Recommended private inputs:

```text
route
routeKey
nonce
intermediate states
memory witness
final preimage
```

---

## Verifier options

Potential implementation paths:

- zkVM guest program for Maze-Time execution;
- Noir circuit for a smaller capsule VM;
- Circom/Groth16 for fixed-size constraints;
- RISC Zero / SP1 verifier adapter on Base.

The Solidity scaffold only includes `IProofVerifier` and `MockProofVerifier`.

---

## Design warning

Large sequential Time-Lock computations can make proof generation expensive.

Recommended first implementation:

```text
Maze complexity: medium
Time-Lock steps: moderate
Memory-Lock: bounded
Proof target: practical for local proving
```

Then gradually increase difficulty after measuring real proving times.
