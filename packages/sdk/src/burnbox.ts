import { encodeAbiParameters, getContractAddress, keccak256, parseAbiParameters, toBytes } from "viem";
import type { BurnBoxRequest, Hex } from "./types.js";

// This bytecode hash must be replaced with the deployed BurnBox init-code hash
// produced by the exact compiler/settings used in deployment.
export const PLACEHOLDER_BURNBOX_INIT_CODE_HASH: Hex =
  "0x0000000000000000000000000000000000000000000000000000000000000000";

export function saltFor(req: BurnBoxRequest, chainId: bigint): Hex {
  return keccak256(
    encodeAbiParameters(
      parseAbiParameters("uint256 chainId, address factory, address token, address user, uint256 roundId, bytes32 userSalt"),
      [chainId, req.factory, req.token, req.user, req.roundId, req.userSalt]
    )
  );
}

export function computeBurnBoxAddress(req: BurnBoxRequest, chainId: bigint, initCodeHash = PLACEHOLDER_BURNBOX_INIT_CODE_HASH): Hex {
  const salt = saltFor(req, chainId);
  return getContractAddress({
    from: req.factory,
    opcode: "CREATE2",
    salt,
    bytecodeHash: initCodeHash
  });
}

export function formatBurnInstruction(address: Hex, tokenSymbol = "LATCH") {
  return [
    "Send the project token to the deterministic BurnBox address below.",
    "Do not send ETH or unrelated assets.",
    `Token: ${tokenSymbol}`,
    `BurnBox: ${address}`,
    "After the transfer is indexed, anyone can finalize the BurnBox to burn the token and mint your Proof NFT."
  ].join("\n");
}
