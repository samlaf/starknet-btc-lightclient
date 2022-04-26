import json
from hashlib import sha256
from binascii import unhexlify

with open("block0.json") as block0_file:
    block0 = json.load(block0_file)
with open("block1.json") as block1_file:
    block1 = json.load(block1_file)

# from bitcoinlib.blocks import Block
# b = Block(block1['hash'], block1['version'], block1['previousblockhash'],
#       block1['merkleroot'], block1['time'], block1['bits'], block1['nonce'])
# print(b.target_hex)

# block header
# [version, previousblockhash, merkleroot, time, bits, nonce]
# [4,       32,                32,         4,    4,    4    ]
# [int,     string,            string,     int,  string, int]
# all little endian

ENDIANNESS = 'little'


def to_bytes(string, unhexlify=True):
    if not string:
        return b''
    if unhexlify:
        try:
            if isinstance(string, bytes):
                string = string.decode()
            s = bytes.fromhex(string)
            return s
        except (TypeError, ValueError):
            pass
    if isinstance(string, bytes):
        return string
    else:
        return bytes(string, 'utf8')


def double_sha256(string, as_hex=False):
    if not as_hex:
        return sha256(sha256(string).digest()).digest()
    else:
        return sha256(sha256(string).digest()).hexdigest()


def big_to_little_endian(s):
    return bytes.fromhex(s)[::-1].hex()


def verifyBlock(block):
    versionHex = big_to_little_endian(block['versionHex'])
    previousBlockHashHex = big_to_little_endian(
        block['previousblockhash']) if 'previousblockhash' in block else (0).to_bytes(32, ENDIANNESS).hex()
    merkleRootHex = big_to_little_endian(block['merkleroot'])
    timeHex = block['time'].to_bytes(4, ENDIANNESS).hex()
    bitsHex = big_to_little_endian(block['bits'])
    nonceB = block['nonce'].to_bytes(4, ENDIANNESS).hex()

    header_hex = versionHex + previousBlockHashHex + \
        merkleRootHex + timeHex + bitsHex + nonceB
    print(len(header_hex), header_hex)
    header_bin = unhexlify(header_hex)
    hash = sha256(sha256(header_bin).digest()).digest()
    print(hash[::-1].hex())


def header_to_cairo(block):
    versionHex = big_to_little_endian(block['versionHex'])
    previousBlockHashHex = big_to_little_endian(
        block['previousblockhash']) if 'previousblockhash' in block else (0).to_bytes(32, ENDIANNESS).hex()
    merkleRootHex = big_to_little_endian(block['merkleroot'])
    timeHex = block['time'].to_bytes(4, ENDIANNESS).hex()
    bitsHex = big_to_little_endian(block['bits'])
    nonceB = block['nonce'].to_bytes(4, ENDIANNESS).hex()

    header_hex = versionHex + previousBlockHashHex + \
        merkleRootHex + timeHex + bitsHex + nonceB
    header_bin = unhexlify(header_hex)

    data = header_bin.hex()
    # print(data)

    # return [data[8*i:8*(i+1)] for i in range(160//8)]
    tmp = [int(data[8*i:8*(i+1)], 16) for i in range(160//8)]
    # for i,d in enumerate(tmp):
    #    print(f'data[{i}] = {d}')
    return tmp


if __name__ == "__main__":
    print(header_to_cairo(block0))
    print(header_to_cairo(block1))

    verifyBlock(block0)
    print(block0['hash'])
    verifyBlock(block1)
    print(block1['hash'])
