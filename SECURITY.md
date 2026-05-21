# Security

Do not use this repository as production code without review and audit.

High-risk areas:

- ZK circuit / zkVM program soundness;
- verifier key mismatch;
- CREATE2 BurnBox address spoofing;
- proof replay / nullifier reuse;
- keeper centralization;
- treasury release logic;
- token burn behavior for non-standard ERC20s.

Report issues privately to the maintainers before public disclosure.
