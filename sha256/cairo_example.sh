#!/bin/bash

cairo-compile sha256_contract.cairo --output sha256_cairo_contract_compiled.json

PYTHONPATH=. cairo-run --program=sha256_cairo_contract_compiled.json \
    --print_output \
    --layout=all \
    --print_info
