export STARKNET_GATEWAY_URL=http://localhost:5000/
export STARKNET_FEEDER_GATEWAY_URL=http://localhost:5000/
#export STARKNET_CHAIN_ID=SN_GOERLI
#export STARKNET_NETWORK_ID=hackathon-0
# unset STARKNET_NETWORK

starknet deploy --contract build/starknet_contract_compiled.json
