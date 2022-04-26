#!/bin/bash

starknet-compile starknet_contract.cairo \
    --disable_hint_validation \
    --output build/starknet_contract_compiled.json \
    --abi build/starknet_contract_abi.json
