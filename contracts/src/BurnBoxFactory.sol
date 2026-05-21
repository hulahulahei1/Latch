// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OwnableLite} from "./OwnableLite.sol";
import {BurnBox} from "./BurnBox.sol";
import {ProofNFT} from "./ProofNFT.sol";

/// @notice Factory for deterministic per-user, per-round BurnBox contracts.
contract BurnBoxFactory is OwnableLite {
    address public immutable token;
    ProofNFT public immutable proofNFT;
    uint256 public immutable hintUnit;

    event BurnBoxDeployed(address indexed box, address indexed user, uint256 indexed roundId, bytes32 salt);
    event BurnFinalized(address indexed box, address indexed user, uint256 indexed roundId, uint256 burnedAmount, uint32 hintLevel, uint256 proofNftId);

    constructor(address initialOwner, address token_, address proofNFT_, uint256 hintUnit_) OwnableLite(initialOwner) {
        token = token_;
        proofNFT = ProofNFT(proofNFT_);
        hintUnit = hintUnit_ == 0 ? 100_000 ether : hintUnit_;
    }

    function saltFor(address user, uint256 roundId, bytes32 userSalt) public view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, address(this), token, user, roundId, userSalt));
    }

    function computeBurnBox(address user, uint256 roundId, bytes32 userSalt) external view returns (address) {
        bytes32 salt = saltFor(user, roundId, userSalt);
        bytes32 initHash = keccak256(abi.encodePacked(
            type(BurnBox).creationCode,
            abi.encode(token, user, roundId, hintUnit)
        ));
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, initHash)))));
    }

    function deploy(address user, uint256 roundId, bytes32 userSalt) public returns (address box) {
        bytes32 salt = saltFor(user, roundId, userSalt);
        box = address(new BurnBox{salt: salt}(token, user, roundId, hintUnit));
        emit BurnBoxDeployed(box, user, roundId, salt);
    }

    function deployAndFinalize(address user, uint256 roundId, bytes32 userSalt) external returns (address box, uint256 proofNftId) {
        box = deploy(user, roundId, userSalt);
        proofNftId = _finalize(box);
    }

    function finalizeExisting(address payable box) external returns (uint256 proofNftId) {
        proofNftId = _finalize(box);
    }

    function _finalize(address box) internal returns (uint256 proofNftId) {
        (uint256 burnedAmount, uint32 hintLevel) = BurnBox(box).finalize();
        address user = BurnBox(box).user();
        uint256 roundId = BurnBox(box).roundId();
        proofNftId = proofNFT.mint(user, roundId, burnedAmount, hintLevel);
        emit BurnFinalized(box, user, roundId, burnedAmount, hintLevel, proofNftId);
    }
}
