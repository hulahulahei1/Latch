// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OwnableLite} from "./OwnableLite.sol";
import {LatchTypes} from "./LatchTypes.sol";

/// @notice Soulbound proof credential for LATCH burn participation.
contract ProofNFT is OwnableLite {
    string public name = "LATCH Proof";
    string public symbol = "LATCH-PROOF";

    address public minter;
    address public credentialOperator;
    uint256 public nextId = 1;

    mapping(uint256 => address) private _ownerOf;
    mapping(address => uint256) private _balanceOf;
    mapping(uint256 => LatchTypes.BurnCredential) private _credentialOf;

    event MinterSet(address indexed minter);
    event CredentialOperatorSet(address indexed operator);
    event Minted(address indexed to, uint256 indexed tokenId, uint256 indexed roundId, uint256 burnedAmount, uint32 hintLevel);
    event Used(uint256 indexed tokenId, uint256 indexed roundId);

    error NotMinter();
    error NotCredentialOperator();
    error Soulbound();
    error InvalidToken();

    constructor(address initialOwner) OwnableLite(initialOwner) {}

    modifier onlyMinter() {
        if (msg.sender != minter) revert NotMinter();
        _;
    }

    modifier onlyCredentialOperator() {
        if (msg.sender != credentialOperator) revert NotCredentialOperator();
        _;
    }

    function setMinter(address newMinter) external onlyOwner {
        minter = newMinter;
        emit MinterSet(newMinter);
    }

    function setCredentialOperator(address newOperator) external onlyOwner {
        credentialOperator = newOperator;
        emit CredentialOperatorSet(newOperator);
    }

    function mint(address to, uint256 roundId, uint256 burnedAmount, uint32 hintLevel) external onlyMinter returns (uint256 tokenId) {
        tokenId = nextId++;
        _ownerOf[tokenId] = to;
        _balanceOf[to] += 1;
        _credentialOf[tokenId] = LatchTypes.BurnCredential({
            roundId: roundId,
            burnedAmount: burnedAmount,
            hintLevel: hintLevel,
            mintedAt: uint64(block.timestamp),
            used: false
        });
        emit Minted(to, tokenId, roundId, burnedAmount, hintLevel);
    }

    function markUsed(uint256 tokenId) external onlyCredentialOperator {
        if (_ownerOf[tokenId] == address(0)) revert InvalidToken();
        _credentialOf[tokenId].used = true;
        emit Used(tokenId, _credentialOf[tokenId].roundId);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _ownerOf[tokenId];
        if (tokenOwner == address(0)) revert InvalidToken();
        return tokenOwner;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf[account];
    }

    function credentialOf(uint256 tokenId) external view returns (LatchTypes.BurnCredential memory) {
        if (_ownerOf[tokenId] == address(0)) revert InvalidToken();
        return _credentialOf[tokenId];
    }

    /// @notice ERC721-like transfer functions intentionally disabled.
    function transferFrom(address, address, uint256) external pure {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256) external pure {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) external pure {
        revert Soulbound();
    }
}
