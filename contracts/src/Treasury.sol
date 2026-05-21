// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OwnableLite} from "./OwnableLite.sol";
import {IERC20} from "./interfaces/IERC20.sol";

/// @notice Minimal treasury with controlled executor release.
contract Treasury is OwnableLite {
    mapping(address => bool) public executor;

    event ExecutorSet(address indexed executor, bool allowed);
    event Released(address indexed asset, address indexed to, uint256 amount);

    error NotExecutor();
    error TransferFailed();

    constructor(address initialOwner) OwnableLite(initialOwner) {}

    receive() external payable {}

    modifier onlyExecutor() {
        if (!executor[msg.sender]) revert NotExecutor();
        _;
    }

    function setExecutor(address account, bool allowed) external onlyOwner {
        executor[account] = allowed;
        emit ExecutorSet(account, allowed);
    }

    function releaseETH(address payable to, uint256 amount) external onlyExecutor {
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert TransferFailed();
        emit Released(address(0), to, amount);
    }

    function releaseERC20(address token, address to, uint256 amount) external onlyExecutor {
        bool ok = IERC20(token).transfer(to, amount);
        if (!ok) revert TransferFailed();
        emit Released(token, to, amount);
    }
}
