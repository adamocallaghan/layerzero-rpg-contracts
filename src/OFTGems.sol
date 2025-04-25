// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {OFT} from "@layerzerolabs/oft-evm/contracts/OFT.sol";

contract OFT_Sepolia is OFT {
    // Game Engine Contract
    address public gameEngine;

    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) OFT(_name, _symbol, _lzEndpoint, _delegate) {
        _mint(msg.sender, 100 ether);
    }

    function setGameEngine(address _gameEngine) public {
        // @note: add onlyDelegate modifier
        gameEngine = _gameEngine;
    }

    function mintGemsToPlayer(
        address _player,
        uint256 _numberOfGemsToMint
    ) public {
        // @note: add onlyGameEngine modifier
        _mint(_player, _numberOfGemsToMint);
    }
}
