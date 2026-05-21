# Agent Integration

LATCH is designed so Claude, Codex, local agents, and custom solver systems can participate without receiving broad wallet authority.

---

## Agent responsibilities

An agent may:

- read active rounds;
- verify capsule hashes;
- compute BurnBox addresses;
- explain burn instructions to the user;
- parse capsule data;
- use hint context from ProofNFT level;
- write solver scripts;
- invoke a prover;
- prepare proof submission calldata.

An agent should not:

- receive the user's private key;
- control unrestricted wallet funds;
- alter reward addresses silently;
- submit proofs without user approval unless scoped permissions are explicitly configured.

---

## CLI pattern

```bash
npx latch round examples/capsule.round-18.json
npx latch burnbox --round 18 --user 0xUser --token 0xToken --factory 0xFactory
npx latch solve examples/capsule.round-18.json
npx latch proof --round 18 --nft 42
```

The current CLI is a scaffold. Production agents should verify addresses and hashes before showing instructions to users.

---

## Recommended permission model

For future smart-account integrations, agent permissions should be scoped to:

```text
contract: RoundManager
method: submitProof
roundId: active round only
nftId: user's ProofNFT only
rewardAddress: user's wallet only
expiry: short window
spend limit: zero or protocol-defined
```

The model is:

```text
Do not trust the agent.
Constrain the agent.
Verify the proof.
```

---

## Optional Base-native extensions

LATCH can later integrate with:

- account abstraction / paymasters for gasless proof submission;
- scoped wallet permissions for agent sessions;
- x402-compatible solver endpoints for optional third-party compute markets;
- attestations for solver reputation and proof history.

These are extensions, not protocol requirements.
