// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "./interfaces/IERC20.sol";

/// @notice Single-use deterministic burn container.
/// @dev This contract may be deployed after tokens are sent to its CREATE2 address.
contract BurnBox {
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    address public immutable factory;
    address public immutable token;
    address public immutable user;
    uint256 public immutable roundId;
    uint256 public immutable hintUnit;

    bool public finalized;

    event Finalized(address indexed user, uint256 indexed roundId, uint256 burnedAmount, uint32 hintLevel);

    error NotFactory();
    error AlreadyFinalized();
    error NothingToBurn();
    error TransferFailed();

    constructor(address token_, address user_, uint256 roundId_, uint256 hintUnit_) {
        factory = msg.sender;
        token = token_;
        user = user_;
        roundId = roundId_;
        hintUnit = hintUnit_ == 0 ? 100_000 ether : hintUnit_;
    }

    function finalize() external returns (uint256 amount, uint32 hintLevel) {
        if (msg.sender != factory) revert NotFactory();
        if (finalized) revert AlreadyFinalized();
        finalized = true;

        amount = IERC20(token).balanceOf(address(this));
        if (amount == 0) revert NothingToBurn();

        bool ok = IERC20(token).transfer(DEAD, amount);
        if (!ok) revert TransferFailed();

        hintLevel = _hintLevel(amount);
        emit Finalized(user, roundId, amount, hintLevel);
    }

    function _hintLevel(uint256 amount) internal view returns (uint32) {
        uint256 level = amount / hintUnit;
        if (level > type(uint32).max) return type(uint32).max;
        return uint32(level);
    }
}
