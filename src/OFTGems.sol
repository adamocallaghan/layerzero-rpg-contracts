// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {OFT} from "@layerzerolabs/oft-evm/contracts/OFT.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract OFTGems is OFT {
    // Game Engine Contract
    address public gameEngine;

    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) OFT(_name, _symbol, _lzEndpoint, _delegate) Ownable(_delegate) {
        _mint(_delegate, 10);
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
