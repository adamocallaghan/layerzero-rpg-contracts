-include .env
# =========================
# === SCRIPT DEPLOYMENT ===
# =========================

# NOTE: if you are *re-deploying* the contracts make sure to change the 'salt' in the DeployONFTCharacter script

deploy-contracts-multichain:
	forge script script/DeployONFTCharacter.s.sol:DeployONFTCharacter --slow --multi --broadcast --verify --account deployer -vvvvv

verify-base-contract:
	forge verify-contract --chain-id 84532 $(ONFT_ADDRESS) src/ONFTCharacter.sol:ONFTCharacter --constructor-args-path base-constructor-args.txt --etherscan-api-key $(BASE_ETHERSCAN_API_KEY)

verify-optimism-contract:
	forge verify-contract --chain-id 11155420  $(ONFT_ADDRESS) src/ONFTCharacter.sol:ONFTCharacter --constructor-args-path base-constructor-args.txt --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY)

# ======================
# === PEER COMMANDS ===
# ======================

set-peers:
	forge script script/SetPeers.s.sol:SetPeers --broadcast --account deployer -vvvvv

get-base-peer:
	cast call $(ONFT_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_BYTES32) --rpc-url $(BASE_SEPOLIA_RPC)

get-optimism-peer:
	cast call $(ONFT_ADDRESS) "isPeer(uint32,bytes32)(bool)" $(BASE_SEPOLIA_LZ_ENDPOINT_ID) $(ONFT_BYTES32) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

# =======================
# === MINT & BALANCES ===
# =======================

mint-onft-on-base:
	cast send $(ONFT_ADDRESS) "mint()" --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

get-your-base-onft-balance:
	cast call $(ONFT_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC)

get-your-optimism-onft-balance:
	cast call $(ONFT_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC)

# =================
# === SEND ONFT ===
# =================

# approve-onft:
# 	cast send $(ONFT_ADDRESS) "approve(address,uint256)" $(ONFT_ADDRESS) 1 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

get-quote-on-base:
	cast call $(ONFT_ADDRESS) "quoteSend((uint32,bytes32,uint256,bytes,bytes,bytes),bool)(uint256,uint256)" "($(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID),$(DEPLOYER_BYTES32_ADDRESS),1,$(MESSAGE_OPTIONS_BYTES),0x,0x)" false --rpc-url $(BASE_SEPOLIA_RPC)

send-onft-from-base-to-optimism:
	cast send $(ONFT_ADDRESS) "send((uint32,bytes32,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40232,0x00000000000000000000000064a822f980dc5f126215d75d11dd8114ed0bdb5f,2,$(MESSAGE_OPTIONS_BYTES),0x,0x)" "(10000000000000000,0)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer --value 0.01ether

# ======================
# === TEMP COMMANDS ====
# ======================

test-address-cast:
	forge script script/TestAddressCast.s.sol:TestAddressCast --account deployer -vvvvv
