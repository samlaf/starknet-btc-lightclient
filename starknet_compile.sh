#!/bin/bash

starknet-compile starknet_contract.cairo \
    --disable_hint_validation \
    --output starknet_contract_compiled.json \
    --abi starknet_contract_abi.json
