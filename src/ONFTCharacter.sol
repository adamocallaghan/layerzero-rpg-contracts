// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {ONFT721Enumerable} from "@layerzerolabs/onft-evm/contracts/onft721/ONFT721Enumerable.sol";

contract ONFTCharacter is ONFT721Enumerable {
    // Game Engine Contract
    address public gameEngine;

    uint256 public mintCount;

    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) ONFT721Enumerable(_name, _symbol, _lzEndpoint, _delegate) {}

    function mint() public {
        _mint(msg.sender, mintCount);
        mintCount++;
    }

    function setGameEngine(address _gameEngine) public {
        // @note: add onlyDelegate modifier
        gameEngine = _gameEngine;
    }

    function mintCharacterToPlayer(address _player) public {
        // @note: add onlyGameEngine modifier
        _mint(_player, mintCount);
        mintCount++;
    }
}
