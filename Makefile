-include .env
# =========================
# === SCRIPT DEPLOYMENT ===
# =========================

# NOTE: if you are *re-deploying* the contracts make sure to change the 'salt' in the DeployONFTCharacter script

deploy-character-multichain: # trying to verify with Etherscan here
	forge script script/DeployONFTCharacter.s.sol:DeployONFTCharacter --slow --multi --broadcast --verify  --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --account deployer -vvvvv

deploy-tool-multichain:
	forge script script/DeployONFTTool.s.sol:DeployONFTTool --slow --multi --broadcast --verify --account deployer -vvvvv

deploy-gems-multichain:
	forge script script/DeployOFTGems.s.sol:DeployOFTGems --slow --multi --broadcast --verify --account deployer -vvvvv

deploy-game-engine-multichain:
	forge script script/DeployOAppGameEngine.s.sol:DeployOAppGameEngine --slow --multi --broadcast --verify --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --account deployer -vvvvv

verify-base-character-contract:
	forge verify-contract --chain-id 84532 $(ONFT_CHARACTER_ADDRESS) src/ONFTCharacter.sol:ONFTCharacter --constructor-args-path character-constructor-args.txt --etherscan-api-key $(BASE_ETHERSCAN_API_KEY)

verify-optimism-character-contract:
	forge verify-contract --chain-id 11155420  $(ONFT_CHARACTER_ADDRESS) src/ONFTCharacter.sol:ONFTCharacter --constructor-args-path character-constructor-args.txt --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY)

verify-base-tool-contract:
	forge verify-contract --chain-id 84532 $(ONFT_TOOL_ADDRESS) src/ONFTTool.sol:ONFTTool --constructor-args-path tool-constructor-args.txt --etherscan-api-key $(BASE_ETHERSCAN_API_KEY)

verify-optimism-tool-contract:
	forge verify-contract --chain-id 11155420  $(ONFT_TOOL_ADDRESS) src/ONFTTool.sol:ONFTTool --constructor-args-path tool-constructor-args.txt --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY)

verify-base-gems-contract:
	forge verify-contract --chain-id 84532 $(OFT_GEMS_ADDRESS) src/OFTGems.sol:OFTGems --constructor-args-path gems-constructor-args.txt --etherscan-api-key $(BASE_ETHERSCAN_API_KEY)

verify-optimism-gems-contract:
	forge verify-contract --chain-id 11155420  $(OFT_GEMS_ADDRESS) src/OFTGems.sol:OFTGems --constructor-args-path gems-constructor-args.txt --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY)

# ======================
# === PEER COMMANDS ===
# ======================

set-peers:
	forge script script/SetPeers.s.sol:SetPeers --broadcast --account deployer -vvvvv

get-base-character-peer:
	cast call $(ONFT_CHARACTER_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_CHARACTER_BYTES32) --rpc-url $(BASE_SEPOLIA_RPC)

get-optimism-character-peer:
	cast call $(ONFT_CHARACTER_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(BASE_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_CHARACTER_BYTES32) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

get-base-tool-peer:
	cast call $(ONFT_TOOL_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_TOOL_BYTES32) --rpc-url $(BASE_SEPOLIA_RPC)

get-optimism-tool-peer:
	cast call $(ONFT_TOOL_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(BASE_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_TOOL_BYTES32) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

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

get-your-base-character-balance:
	cast call $(ONFT_CHARACTER_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC)

get-your-optimism-character-balance:
	cast call $(ONFT_CHARACTER_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

get-your-base-tool-balance:
	cast call $(ONFT_TOOL_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC)

get-your-optimism-tool-balance:
	cast call $(ONFT_TOOL_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

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

# ==============
# === BRIDGE ===
# ==============

bridge-character-and-gems-from-base-to-optimism: # requires you to have 10 gems
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridge(uint256,uint256)" 1 0 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer

bridge-character-and-gems-from-base-to-optimism-with-bytes: # requires you to have 10 gems
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "bridge(uint256,uint256,bytes,bytes,bytes,bytes32)" 2 0 $(MESSAGE_OPTIONS_BYTES) 0x 0x $(DEPLOYER_BYTES32_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer

send-character-from-base-to-optimism-via-test-bridge-function:
	cast send $(OAPP_GAME_ENGINE_ADDRESS) "testBridge((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,1,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

# =================
# === SEND ONFT ===
# =================

approve-oapp-to-bridge-onft-character-on-base:
	cast send $(ONFT_CHARACTER_ADDRESS) "approve(address,uint256)" $(OAPP_GAME_ENGINE_ADDRESS) 0 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

get-character-quote-on-base:
	cast call $(ONFT_CHARACTER_ADDRESS) "quoteSend((uint32,bytes32,uint256,bytes,bytes,bytes),bool)(uint256,uint256)" "($(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID),$(DEPLOYER_BYTES32_ADDRESS),1,$(MESSAGE_OPTIONS_BYTES),0x,0x)" false --rpc-url $(BASE_SEPOLIA_RPC)

send-character-from-base-to-optimism:
	cast send $(ONFT_CHARACTER_ADDRESS) "send((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,0,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

send-tool-from-base-to-optimism:
	cast send $(ONFT_TOOL_ADDRESS) "send((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,0,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

# ======================
# === TEMP COMMANDS ====
# ======================

test-address-cast:
	forge script script/TestAddressCast.s.sol:TestAddressCast --account deployer -vvvvv
