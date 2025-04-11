-include .env
# =========================
# === SCRIPT DEPLOYMENT ===
# =========================

# NOTE: if you are *re-deploying* the contracts make sure to change the 'salt' in the DeployToBase and DeployToArbitrum scripts

deploy-contracts-to-base:
	forge script script/DeployONFTCharacter.s.sol:DeployONFTCharacter --broadcast --verify --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

test-address-cast:
	forge script script/TestAddressCast.s.sol:TestAddressCast --account deployer -vvvvv