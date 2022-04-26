import os
import time
import json
import subprocess
import requests
from dotenv import load_dotenv

from lightclient import header_to_cairo

def subprocess_run(cmd):
    result = subprocess.run(cmd, stdout=subprocess.PIPE)
    result = result.stdout.decode('utf-8')[:-1]
    return result

def verify_block(contract_addr, height, data):
    data = " ".join([str(i) for i in data])
    cmd = f"starknet invoke --network_id=hackathon-0 --gateway_url=https://hackathon-0.starknet.io --feeder_gateway_url=https://hackathon-0.starknet.io --address {contract_addr} --abi starknet_contract_abi.json --function process_block --inputs {height} 20 " + data
    cmd = cmd.split(' ')
    ret = subprocess_run(cmd)
    ret = ret.split(': ')
    tx_hash = ret[-1]
    return tx_hash

def poll_until_accepted(list_of_tx_hashes, interval_in_sec):
    accepted_list = [False for _ in list_of_tx_hashes]

    while True:
        all_accepted = True
        print(f'> begin polling tx status.')
        for i, tx_hash in enumerate(list_of_tx_hashes):
            if accepted_list[i]:
                continue
            cmd = f"starknet tx_status --network_id=hackathon-0 --gateway_url=https://hackathon-0.starknet.io --feeder_gateway_url=https://hackathon-0.starknet.io --hash={tx_hash}".split(' ')
            ret = subprocess_run(cmd)
            ret = json.loads(ret)
            if ret['tx_status'] != 'ACCEPTED_ONCHAIN':
                print(f"> {tx_hash} ({ret['tx_status']}) not accepted onchain yet.")
                all_accepted = False
                break
            else:
                print(f"> {i}th hash {tx_hash} is accepted onchain.")
                accepted_list[i] = True
        if all_accepted:
            break
        else:
            print(f'> retry polling in {interval_in_sec} seconds.')
            time.sleep(interval_in_sec)
    print(f'> all tx hashes are accepted onchain.')
    return

def get_block_by_height(height):
    # Retrieve block hash from height
    block_hash = requests.post(
        'https://btc.getblock.io/mainnet/',
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': API_KEY
        },
        json={
            "jsonrpc": "2.0",
            "method": "getblockhash",
            "params": [height],
            "id": "getblock.io"
        }).json()['result']

    # Retrieve block header from hash
    block = requests.post(
        'https://btc.getblock.io/mainnet/',
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': API_KEY
        },
        json={
            "jsonrpc": "2.0",
            "method": "getblock",
            "params": [block_hash],
            "id": "getblock.io"
        }).json()['result']
    return block

if __name__ == "__main__":
    load_dotenv()
    API_KEY = os.environ["GETBLOCK_API_KEY"]
    CONTRACT_ADDR = os.environ["CONTRACT_ADDR"]

    block_height = 1
    block = get_block_by_height(block_height)

    data = header_to_cairo(block)
    print(data)

    txhash = verify_block(CONTRACT_ADDR, block_height, data)
    #poll_until_accepted([txhash], 5)
