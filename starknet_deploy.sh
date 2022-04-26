export STARKNET_GATEWAY_URL=https://hackathon-0.starknet.io
export STARKNET_FEEDER_GATEWAY_URL=https://hackathon-0.starknet.io
export STARKNET_CHAIN_ID=SN_GOERLI
export STARKNET_NETWORK_ID=hackathon-0
unset STARKNET_NETWORK

# Check if the CLI works.
starknet get_block
