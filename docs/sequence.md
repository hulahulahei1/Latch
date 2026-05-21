# Sequence

## Full sequence

```mermaid
sequenceDiagram
    participant R as RoundManager
    participant V as Randomness / VRF Adapter
    participant C as Capsule Generator
    participant A as Agent CLI / SDK
    participant U as User Wallet
    participant F as BurnBoxFactory
    participant B as BurnBox
    participant N as ProofNFT
    participant P as Local Prover
    participant Z as ZK Verifier
    participant L as ActionLocker
    participant T as Treasury

    R->>V: request round seed
    V-->>R: return seed
    R->>C: derive Maze-Time Capsule
    C-->>R: capsuleHash, programHash, target, difficulty
    R->>R: store round commitment

    A->>R: read active round
    A->>F: compute BurnBox address
    F-->>A: deterministic address
    A-->>U: display address and verification data
    U->>B: transfer project token to computed address

    F->>B: deploy if needed and finalize
    B->>B: burn / dead-transfer token balance
    B->>N: mint ProofNFT to user
    N-->>U: round credential

    A->>N: read credential and hint level
    A->>C: load public capsule and hint context
    C-->>A: capsule data
    A->>A: solve maze path
    A->>A: run Time-Lock / Memory-Lock
    A->>P: generate proof
    P-->>U: proof payload

    U->>R: submit proof
    R->>N: verify NFT ownership and round binding
    R->>Z: verify proof
    Z-->>R: valid / invalid

    alt valid proof
        R->>R: mark nullifier used
        R->>L: schedule unlocked action
        L->>T: request funds or state action after delay
        T-->>L: release allowed action
    else invalid proof
        R-->>U: revert
    end
```

## State machine

```text
RoundCreated
  → CapsuleCommitted
  → BurnBoxComputed
  → TokenDeposited
  → BurnFinalized
  → ProofNFTMinted
  → CapsuleSolvedOffchain
  → ProofSubmitted
  → ProofVerified
  → ActionScheduled
  → CooldownElapsed
  → ActionClaimed
```
