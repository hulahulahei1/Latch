// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OwnableLite} from "./OwnableLite.sol";
import {IERC20} from "./interfaces/IERC20.sol";

/// @notice Generic cooldown locker for rewards or proof-unlocked actions.
contract ActionLocker is OwnableLite {
    struct Lock {
        address asset;
        address recipient;
        uint256 amount;
        uint64 unlockTime;
        bool claimed;
    }

    uint256 public nextLockId = 1;
    mapping(uint256 => Lock) public locks;
    mapping(address => bool) public scheduler;

    event SchedulerSet(address indexed scheduler, bool allowed);
    event Locked(uint256 indexed lockId, address indexed asset, address indexed recipient, uint256 amount, uint64 unlockTime);
    event Claimed(uint256 indexed lockId, address indexed recipient);

    error NotScheduler();
    error NotRecipient();
    error NotUnlocked();
    error AlreadyClaimed();
    error TransferFailed();

    constructor(address initialOwner) OwnableLite(initialOwner) {}

    receive() external payable {}

    modifier onlyScheduler() {
        if (!scheduler[msg.sender]) revert NotScheduler();
        _;
    }

    function setScheduler(address account, bool allowed) external onlyOwner {
        scheduler[account] = allowed;
        emit SchedulerSet(account, allowed);
    }

    function lockETH(address recipient, uint64 unlockTime) external payable onlyScheduler returns (uint256 lockId) {
        lockId = _createLock(address(0), recipient, msg.value, unlockTime);
    }

    function lockERC20(address asset, address recipient, uint256 amount, uint64 unlockTime) external onlyScheduler returns (uint256 lockId) {
        bool ok = IERC20(asset).transferFrom(msg.sender, address(this), amount);
        if (!ok) revert TransferFailed();
        lockId = _createLock(asset, recipient, amount, unlockTime);
    }

    function claim(uint256 lockId) external {
        Lock storage l = locks[lockId];
        if (msg.sender != l.recipient) revert NotRecipient();
        if (block.timestamp < l.unlockTime) revert NotUnlocked();
        if (l.claimed) revert AlreadyClaimed();
        l.claimed = true;

        if (l.asset == address(0)) {
            (bool ok,) = payable(l.recipient).call{value: l.amount}("");
            if (!ok) revert TransferFailed();
        } else {
            bool ok = IERC20(l.asset).transfer(l.recipient, l.amount);
            if (!ok) revert TransferFailed();
        }

        emit Claimed(lockId, l.recipient);
    }

    function _createLock(address asset, address recipient, uint256 amount, uint64 unlockTime) internal returns (uint256 lockId) {
        lockId = nextLockId++;
        locks[lockId] = Lock(asset, recipient, amount, unlockTime, false);
        emit Locked(lockId, asset, recipient, amount, unlockTime);
    }
}
