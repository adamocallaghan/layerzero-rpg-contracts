// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { ONFT721 } from "@layerzerolabs/onft-evm/contracts/onft721/ONFT721.sol";

contract ONFTCharacter is ONFT721 {
    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) ONFT721(_name, _symbol, _lzEndpoint, _delegate) {}

    uint256 public mintCount;

    // Used by game engine to add final stage game elements and protect final action in game
    mapping(address player => bool gameStatus) public playerProgress;

    function mint() public {
        _mint(msg.sender, mintCount);
        mintCount++;
    }
}