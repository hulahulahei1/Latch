# Scripts

Deployment scripts are intentionally not included in this scaffold because production deployment depends on:

- selected verifier system;
- Base network target;
- token address;
- treasury action policy;
- ownership / governance model.

Recommended deployment order:

1. `ProofNFT`
2. `BurnBoxFactory`
3. `RoundManager`
4. set `ProofNFT.minter = BurnBoxFactory`
5. set `ProofNFT.credentialOperator = RoundManager`
6. deploy verifier adapter
7. deploy treasury / locker modules
