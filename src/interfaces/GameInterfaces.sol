pragma solidity ^0.8.22;

interface IOFTGems {
    function mintGemsToPlayer(
        address _player,
        uint256 _numberOfGemsToMint
    ) external payable;
    function balanceOf(address _player) external view returns (uint256);
}

interface IONFTCharacter {
    function mintCharacterToPlayer(address _player) external payable;
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

interface IONFTTool {
    function mintToolToPlayer(address _player) external payable;
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}