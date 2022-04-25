import json
from hashlib import sha256

with open("block0.json") as block0_file:
    block0 = json.load(block0_file)
with open("block1.json") as block1_file:
    block1 = json.load(block1_file)

# block header
# [version, previousblockhash, merkleroot, time, bits, nonce]
# [4,       32,                32,         4,    4,    4    ]
# [int,     string,            string,     int,  string, int]
# all little endian (??)

ENDIANNESS = 'little'


def verifyBlock(block):
    versionB = block['version'].to_bytes(4, ENDIANNESS)
    previousBlockHashB = bytes.fromhex(
        block['previousBlock']) if 'previousBlock' in block else (0).to_bytes(32, ENDIANNESS)
    merkleRootB = bytes.fromhex(block['merkleroot'])
    timeB = block['time'].to_bytes(4, ENDIANNESS)
    bitsB = bytes.fromhex(block['bits'])
    nonceB = block['nonce'].to_bytes(4, ENDIANNESS)

    blockHeaderB = versionB + previousBlockHashB + \
        merkleRootB + timeB + bitsB + nonceB
    print(sha256(bytes.fromhex(sha256(blockHeaderB).hexdigest())).hexdigest())
    print(block['hash'])


def verify(prevblock, curblock):
    curblock.previousblockhash == prevblock.hash


verifyBlock(block1)
