pragma solidity ^0.8.22;

struct OftSendParam {
    uint32 dstEid; // Destination endpoint ID.
    bytes32 to; // Recipient address.
    uint256 amountLD; // Amount to send in local decimals.
    uint256 minAmountLD; // Minimum amount to send in local decimals.
    bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
    bytes composeMsg; // The composed message for the send() operation.
    bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
}

struct OftMessagingFee {
    uint256 nativeFee;
    uint256 lzTokenFee;
}

interface IOFTGems {
    function mintGemsToPlayer(
        address _player,
        uint256 _numberOfGemsToMint
    ) external payable;
    function balanceOf(address _player) external view returns (uint256);
    function send(OftSendParam memory _oftSendParam, OftMessagingFee memory _fee,
        address _refundAddress) external payable;
}

interface IONFTCharacter {
    function mintCharacterToPlayer(address _player) external payable;
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

interface IONFTTool {
    function mintToolToPlayer(address _player) external payable;
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}