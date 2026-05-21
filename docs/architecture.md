# Architecture

LATCH is structured as a protocol layer, not an application frontend.

Its architecture is split into five layers:

```text
Agent layer      Claude / Codex / local solver / custom AI runtime
SDK layer        capsule parsing, BurnBox computation, proof submission helpers
Proof layer      Maze-Time program + ZK proof generation
Contract layer   rounds, burn credentials, proof verification, action locks
Base layer       settlement, verification, token accounting, execution events
```

---

## Contract modules

### RoundManager

Owns the lifecycle of a round.

A round records:

- `roundId`;
- `capsuleHash`;
- `programHash`;
- `difficulty`;
- `target`;
- `verifier`;
- time window;
- solved status.

It does not store the answer.

### BurnBoxFactory

Computes deterministic burn addresses through CREATE2.

A user can receive a BurnBox address before the contract is deployed. When tokens are sent to that address, anyone can later deploy and finalize the BurnBox.

This prevents the protocol from giving users a private-key controlled deposit address.

### BurnBox

A single-use contract bound to:

- one user;
- one round;
- one project token;
- one ProofNFT contract.

When finalized, it burns all project tokens held by the BurnBox and mints or upgrades the user's round credential.

### ProofNFT

A soulbound credential proving that a user burned into a specific round.

The NFT is not meant to be a tradable collectible. It is a protocol credential.

### IProofVerifier

The verifier interface used by `RoundManager`.

Production deployments should replace `MockProofVerifier` with a real verifier adapter, for example:

- RISC Zero verifier;
- Succinct SP1 verifier;
- Noir/Barretenberg verifier;
- Groth16/Plonk verifier.

### Treasury and ActionLocker

Treasury holds protocol assets. ActionLocker delays and cools down protocol actions after valid proofs.

The scaffold avoids hardcoding a specific economic action. A production project can wire valid proofs to:

- scheduled buybacks;
- delayed reward claims;
- data unlocks;
- agent task settlement;
- access credentials;
- vault operations.

---

## Agent flow

Agents do not receive wallet authority by default.

They receive:

- public capsule data;
- hint context derived from ProofNFT level;
- a deterministic BurnBox address;
- proof-generation instructions;
- typed data for submission.

The protocol trusts proofs, not model text.

---

## Design rule

No module should require the chain to trust an agent's natural-language output.

If an agent claims it solved a capsule, it must produce a proof.
