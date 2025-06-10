-include .env
# =========================
# === SCRIPT DEPLOYMENT ===
# =========================

# NOTE: if you are *re-deploying* the contracts make sure to change the 'salt' in the DeployONFTCharacter script

deploy-character-multichain:
	forge script script/DeployONFTCharacter.s.sol:DeployONFTCharacter --slow --multi --broadcast --verify  --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --account deployer -vvvvv

deploy-tool-multichain:
	forge script script/DeployONFTTool.s.sol:DeployONFTTool --slow --multi --broadcast --verify --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --account deployer -vvvvv

deploy-gems-multichain:
	forge script script/DeployOFTGems.s.sol:DeployOFTGems --slow --multi --broadcast --verify --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --account deployer -vvvvv

deploy-game-engine-multichain:
	forge script script/DeployOAppGameEngine.s.sol:DeployOAppGameEngine --slow --multi --broadcast --verify --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --account deployer --via-ir -vvvvv

set-peers:
	forge script script/SetPeers.s.sol:SetPeers --broadcast --account deployer --via-ir -vvvvv

sanity-check:
	forge script script/SanityCheck.s.sol:SanityCheck --broadcast --account deployer --via-ir -vvvvv

read-address-from-broadcast-json:
	forge script script/CheckScript.s.sol:CheckScript

# ==============
# === BRIDGE ===
# ==============

# bridge:
# - checks eid of chain
# - if user is on Base and has 10 gems
# ...it bridges their character over to Optimism
send-character-from-base-to-optimism-via-main-bridge-function:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridge((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,12,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

# bridgeMulti:
# - checks the eid of chain
# - bridges both the character & tool across
# - for now make sure the character & tool have THE SAME tokenId (I will fix this shortly!)
send-character-from-base-to-optimism-via-bridge-multi-function:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridgeMulti((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,0,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.03ether

# bridgeMultiWithTokenIds:
# - checks the eid of chain
# - bridges both the character & tool across
# - character tokenId is taken from the SendParam, tool tokenId is passed in separately
send-character-from-base-to-optimism-via-bridge-multi-function-with-token-ids:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridgeMultiWithTokenIds((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address,uint256)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,8,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) 9 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.05ether

# next command is a copy of above, but with "numberOfGems" in params (,uin256) and passed in
# send-character-from-base-to-optimism-via-bridge-multi-function-with-token-ids:
# 	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridgeMultiWithTokenIds((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address,uint256,uint256)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,8,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) 9 1000000000000000000 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.05ether

# =================================================================================
# === bridgeToolDirect: calls our internal _bridgeTool() function and that's it ===
# =================================================================================

# bridgeToolDirect: Base => Optimism
send-tool-from-base-to-optimism-via-bridge-tool-direct:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridgeToolDirect((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,22,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

# bridgeToolDirect: Optimsim => Base
send-tool-from-optimism-to-base-via-bridge-tool-direct:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridgeToolDirect((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40245,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,32,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) --account deployer --value 0.01ether

# =========================================
# testBridgeTool & testBridgeCharacter:
# these functions on our OAPP just call the
# ONFT contracts directly from within their
# public functions
# =========================================

# ADAM NOTE: THE BELOW ARE WORKING ALSO (JUST BEWARE THE OUTSTANDING ISSUE AROUND GAMEENGINE NOT HAVING TOKENS)

# testBridgeCharacter: Base => Optimism
send-character-from-base-to-optimism-via-test-bridge-character-function:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "testBridgeCharacter((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,11,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

# testBridgeTool: Base => Optimism
send-tool-from-base-to-optimism-via-test-bridge-tool-function:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "testBridgeTool((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,12,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

# testBridgeCharacter: Optimsim => Base
send-character-from-optimism-to-base-via-test-bridge-character-function:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "testBridgeCharacter((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40245,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,21,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) --account deployer --value 0.01ether

# testBridgeTool: Optimsim => Base
send-tool-from-optimism-to-base-via-test-bridge-tool-function:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "testBridgeTool((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40245,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,22,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) --account deployer --value 0.01ether

# NOTE THAT GEMS OFT CONTRACT NEEDS TO HAVE THE SEND FUNC OVERRIDDEN TO PASS USER ADDRESS INSTEAD OF MSG.SENDER
send-gems-from-base-to-optimism-via-test-bridge-gems-function:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "testBridgeGems((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,1000000000000000000,1000000000000000000,0x00030100110100000000000000000000000000030d40,0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether -vvvvv

# ===================================================================
# === Send ONFT Character & Tool *DIRECTLY* using their contracts ===
# ===================================================================

# ADAM NOTE: THE BELOW WORK AS OF 29TH MAY 2025

send-character-from-base-to-optimism:
	cast send $(ONFT_CHARACTER_ADDRESS) "send((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,10,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

send-tool-from-base-to-optimism:
	cast send $(ONFT_TOOL_ADDRESS) "send((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,11,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

send-character-from-optimism-to-base:
	cast send $(ONFT_CHARACTER_ADDRESS) "send((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40245,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,20,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) --account deployer --value 0.01ether

send-tool-from-optimism-to-base:
	cast send $(ONFT_TOOL_ADDRESS) "send((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40245,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,21,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) --account deployer --value 0.01ether

send-gems-from-base-to-optimism:
	cast send $(OFT_GEMS_ADDRESS) "send((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,1000000000000000000,1000000000000000000,0x00030100110100000000000000000000000000030d40,0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether -vvvvv

call-quote-send-on-base-gems-contract:
	cast call $(OFT_GEMS_ADDRESS) "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)(uint,uint)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,1000000000000000000,1000000000000000000,0x00030100110100000000000000000000000000030d40,0x,0x)" false --rpc-url $(BASE_SEPOLIA_RPC)

# ======================
# === Other Commands ===
# ======================

approve-oapp-to-bridge-onft-character-on-base:
	cast send $(ONFT_CHARACTER_ADDRESS) "approve(address,uint256)" $(OAPP_GAME_ENGINE_ADDRESS) 0 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

get-character-quote-on-base:
	cast call $(ONFT_CHARACTER_ADDRESS) "quoteSend((uint32,bytes32,uint256,bytes,bytes,bytes),bool)(uint256,uint256)" "($(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID),$(DEPLOYER_BYTES32_ADDRESS),1,$(MESSAGE_OPTIONS_BYTES),0x,0x)" false --rpc-url $(BASE_SEPOLIA_RPC)

test-address-cast:
	forge script script/TestAddressCast.s.sol:TestAddressCast --account deployer -vvvvv

# ==========================
# === GEMS - MINT DIRECT ===
# ==========================

mint-gems-to-user-on-base:
	cast send $(OFT_GEMS_ADDRESS) "mintGemsToPlayer(address,uint256)" $(DEPLOYER_PUBLIC_ADDRESS) 10 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer

get-your-base-gems-balance:
	cast call $(OFT_GEMS_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC)

mint-gems-to-user-on-optimism:
	cast send $(OFT_GEMS_ADDRESS) "mintGemsToPlayer(address,uint256)" $(DEPLOYER_PUBLIC_ADDRESS) 10 --rpc-url $(OPTIMISM_SEPOLIA_RPC) --account deployer

get-your-optimism-gems-balance:
	cast call $(OFT_GEMS_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

# =======================
# === MINT & BALANCES ===
# =======================

mint-character-from-game-engine:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "mintCharacter(address)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

mint-character-on-base:
	cast send $(ONFT_CHARACTER_ADDRESS) "mint()" --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

mint-tool-from-game-engine-on-optimism: # requires you to have 10 gems & only available on optimism sepolia
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "mintTool(address)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) --account deployer -vvvvv

mint-tool-on-base:
	cast send $(ONFT_TOOL_ADDRESS) "mint()" --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

get-owner-of-tool-by-id-on-base:
	cast call $(ONFT_TOOL_ADDRESS) "ownerOf(uint256)(address)" 9 --rpc-url $(BASE_SEPOLIA_RPC)

get-owner-of-character-by-id-on-base:
	cast call $(ONFT_CHARACTER_ADDRESS) "ownerOf(uint256)(address)" 8 --rpc-url $(BASE_SEPOLIA_RPC)

get-owner-of-tool-by-id-on-optimism:
	cast call $(ONFT_TOOL_ADDRESS) "ownerOf(uint256)(address)" 9 --rpc-url $(OPTIMISM_SEPOLIA_RPC)

get-owner-of-character-by-id-on-optimism:
	cast call $(ONFT_CHARACTER_ADDRESS) "ownerOf(uint256)(address)" 8 --rpc-url $(OPTIMISM_SEPOLIA_RPC)

get-your-base-character-balance:
	cast call $(ONFT_CHARACTER_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC)

get-your-optimism-character-balance:
	cast call $(ONFT_CHARACTER_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

get-your-base-tool-balance:
	cast call $(ONFT_TOOL_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC)

get-your-optimism-tool-balance:
	cast call $(ONFT_TOOL_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

get-your-base-gems-balance:
	cast call $(OFT_GEMS_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC)

# =======================
# === Verify Commands ===
# =======================


# verify-base-character-contract:
# 	forge verify-contract --chain-id 84532 $(ONFT_CHARACTER_ADDRESS) src/ONFTCharacter.sol:ONFTCharacter --constructor-args-path character-constructor-args.txt --etherscan-api-key $(BASE_ETHERSCAN_API_KEY)

# verify-optimism-character-contract:
# 	forge verify-contract --chain-id 11155420  $(ONFT_CHARACTER_ADDRESS) src/ONFTCharacter.sol:ONFTCharacter --constructor-args-path character-constructor-args.txt --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY)

# verify-base-tool-contract:
# 	forge verify-contract --chain-id 84532 $(ONFT_TOOL_ADDRESS) src/ONFTTool.sol:ONFTTool --constructor-args-path tool-constructor-args.txt --etherscan-api-key $(BASE_ETHERSCAN_API_KEY)

# verify-optimism-tool-contract:
# 	forge verify-contract --chain-id 11155420  $(ONFT_TOOL_ADDRESS) src/ONFTTool.sol:ONFTTool --constructor-args-path tool-constructor-args.txt --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY)

# verify-base-gems-contract:
# 	forge verify-contract --chain-id 84532 $(OFT_GEMS_ADDRESS) src/OFTGems.sol:OFTGems --constructor-args-path gems-constructor-args.txt --etherscan-api-key $(BASE_ETHERSCAN_API_KEY)

# verify-optimism-gems-contract:
# 	forge verify-contract --chain-id 11155420  $(OFT_GEMS_ADDRESS) src/OFTGems.sol:OFTGems --constructor-args-path gems-constructor-args.txt --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY)


# ============================
# === CHECK PEERS COMMANDS ===
# ============================

get-base-character-peer:
	cast call $(ONFT_CHARACTER_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_CHARACTER_BYTES32) --rpc-url $(BASE_SEPOLIA_RPC)

get-optimism-character-peer:
	cast call $(ONFT_CHARACTER_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(BASE_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_CHARACTER_BYTES32) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

get-base-tool-peer:
	cast call $(ONFT_TOOL_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_TOOL_BYTES32) --rpc-url $(BASE_SEPOLIA_RPC)

get-optimism-tool-peer:
	cast call $(ONFT_TOOL_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(BASE_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_TOOL_BYTES32) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

# ================================
# === Old Bridge/Send Commands ===
# ================================


bridge-character-and-gems-from-base-to-optimism: # requires you to have 10 gems
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridge(uint256,uint256)" 1 0 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer

bridge-character-and-gems-from-base-to-optimism-with-bytes: # requires you to have 10 gems
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridge(uint256,uint256,bytes,bytes,bytes,bytes32)" 2 0 $(MESSAGE_OPTIONS_BYTES) 0x 0x $(DEPLOYER_BYTES32_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer

mint-char-loop:
	forge script script/MintCharLoop.s.sol:MintCharLoop --broadcast --account deployer -vvvvv