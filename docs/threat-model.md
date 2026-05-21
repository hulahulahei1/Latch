# Threat Model

LATCH is designed around distrust of natural-language agent output.

The protocol should trust only:

- committed round data;
- deterministic BurnBox addresses;
- burned token balance;
- soulbound ProofNFT credentials;
- verifier-checked proofs;
- nullifier state.

---

## Threat: fake BurnBox address

A malicious UI or agent may show a user a fake address.

Mitigation:

- BurnBox address must be computed from Factory onchain parameters;
- SDK should display factory address, salt, user, token, and round;
- users and agents can recompute the address independently.

---

## Threat: private-key deposit wallet

If the protocol generates ordinary wallets, users must trust whoever controls the key.

Mitigation:

- use CREATE2 contract addresses;
- no private key exists;
- BurnBox code is public;
- finalization is permissionless.

---

## Threat: proof replay

A valid proof could be reused.

Mitigation:

- every proof binds a nullifier;
- `RoundManager` rejects used nullifiers;
- public inputs bind user, round, nftId, capsuleHash, rewardAddress.

---

## Threat: copied solution

A solver may copy another solver's answer.

Mitigation:

- answer is not revealed;
- proof binds the solver's identity and NFT credential;
- optional commit phase may still be used for non-ZK fallback modes.

---

## Threat: project-controlled questions

If the project manually chooses题目, it can favor insiders.

Mitigation:

- use deterministic capsule generation;
- seed rounds with verifiable randomness;
- publish generator code;
- commit capsule hash before solving starts.

---

## Threat: CUDA domination

Pure hash puzzles can be dominated by GPU farms.

Mitigation:

- use Maze-Time Capsules;
- require path analysis before time-lock;
- use memory-lock lanes;
- make hints reduce reasoning complexity, not just hash work.

This does not eliminate hardware advantage, but it reduces simple parallel brute force dominance.

---

## Threat: verifier bug

The highest-risk component is the ZK verifier or program.

Mitigation:

- keep verifier adapters isolated;
- bind all public inputs;
- generate test vectors;
- audit circuits / zkVM guests;
- use staged caps before large value flows.

---

## Threat: keeper centralization

If only one keeper can finalize burns or actions, protocol liveness depends on it.

Mitigation:

- finalization should be permissionless;
- keepers should be helpers, not authorities;
- users should be able to call finalize directly if they want.
