# %builtins range_check bitwise
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256, uint256_lt
from utils import swap_endianness_64, get_target
from sha256.sha256_contract import compute_sha256
from utils.array_comparison import arr_eq
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

struct BTCHeader:
    member version : felt
    member previous : felt*
    member merkle_root : felt*
    member time : felt
    member bits : felt
    member nonce : felt
    member data : felt*
end

# version       :  4 bytes
# previous hash : 32 bytes
# merkle root   : 32 bytes
# time          :  4 bytes
# bits          :  4 bytes
# nonce         :  4 bytes

# Assuming data is the header packed as an array of 4 bytes
func prepare_header{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(data : felt*) -> (
        res : BTCHeader):
    alloc_locals
    let (previous : felt*) = alloc()
    let (merkle_root : felt*) = alloc()
    let (version) = swap_endianness_64(data[0], 4)

    let (prev0) = swap_endianness_64(data[7] * 2 ** 32 + data[8], 8)
    let (prev1) = swap_endianness_64(data[5] * 2 ** 32 + data[6], 8)
    let (prev2) = swap_endianness_64(data[3] * 2 ** 32 + data[4], 8)
    let (prev3) = swap_endianness_64(data[1] * 2 ** 32 + data[2], 8)
    assert previous[0] = prev0
    assert previous[1] = prev1
    assert previous[2] = prev2
    assert previous[3] = prev3

    let (merkle0) = swap_endianness_64(data[15] * 2 ** 32 + data[16], 8)
    let (merkle1) = swap_endianness_64(data[13] * 2 ** 32 + data[14], 8)
    let (merkle2) = swap_endianness_64(data[11] * 2 ** 32 + data[12], 8)
    let (merkle3) = swap_endianness_64(data[09] * 2 ** 32 + data[10], 8)

    assert merkle_root[0] = merkle0
    assert merkle_root[1] = merkle1
    assert merkle_root[2] = merkle2
    assert merkle_root[3] = merkle3
    let (time) = swap_endianness_64(data[17], 4)
    let (bits) = swap_endianness_64(data[18], 4)
    let (nonce) = swap_endianness_64(data[19], 4)
    return (res=BTCHeader(version, previous, merkle_root, time, bits, nonce, data))
end

func process_header{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        header : BTCHeader, prev_header_hash : felt*) -> (current_header_hash : felt*):
    alloc_locals

    # WIP: Compute SHA256 of serialized header (big endian)
    let header_bytes = header.data
    let (out1, out2) = compute_sha256(header_bytes, 55)  # TODO: Change 55 -> 80 when supported
    let (local curr_header_hash : felt*) = alloc()
    assert curr_header_hash[0] = out1
    assert curr_header_hash[1] = out2

    # Verify previous block header with provided hash
    let (prev_hash_eq) = arr_eq(prev_header_hash, 2, curr_header_hash, 2)
    # assert prev_hash_eq = 1

    # TODO: Verify difficulty target
    # - Parse bits into target and convert to Uint256

    let (target) = get_target(header.bits)
    let hash = Uint256(out1, out2)
    let (res) = uint256_lt(hash, target)
    assert res = 1

    # TODO: Verify difficulty target interval using timestamps

    # TODO: Return current header hash
    return (curr_header_hash)
end

func main{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals

    # Block 0
    let (header_data0 : felt*) = alloc()
    assert header_data0[0] = 16777216
    assert header_data0[1] = 0
    assert header_data0[2] = 0
    assert header_data0[3] = 0
    assert header_data0[4] = 0
    assert header_data0[5] = 0
    assert header_data0[6] = 0
    assert header_data0[7] = 0
    assert header_data0[8] = 0
    assert header_data0[9] = 1000599037
    assert header_data0[10] = 2054886066
    assert header_data0[11] = 2059873342
    assert header_data0[12] = 1735823201
    assert header_data0[13] = 2143820739
    assert header_data0[14] = 2290766130
    assert header_data0[15] = 983546026
    assert header_data0[16] = 1260281418
    assert header_data0[17] = 699096905
    assert header_data0[18] = 4294901789
    assert header_data0[19] = 497822588
    let (block_header0) = prepare_header(header_data0)
    %{
        print(f'version = {ids.block_header0.version:x}') 
        print('previous', list(map(hex, memory.get_range(ids.block_header0.previous, 4))))
        print('merkle', list(map(hex, memory.get_range(ids.block_header0.merkle_root, 4))))
        print(f'time = {ids.block_header0.time:x}')
        print(f'bits = {ids.block_header0.bits:x}')
        print(f'nonce = {ids.block_header0.nonce:x}')
    %}

    # Block 1
    let (header_data1 : felt*) = alloc()
    assert header_data1[0] = 16777216
    assert header_data1[1] = 1877117962
    assert header_data1[2] = 3069293426
    assert header_data1[3] = 3248923206
    assert header_data1[4] = 2925786959
    assert header_data1[5] = 2468250469
    assert header_data1[6] = 3780774044
    assert header_data1[7] = 1758861568
    assert header_data1[8] = 0
    assert header_data1[9] = 2552254973
    assert header_data1[10] = 508274500
    assert header_data1[11] = 3149817870
    assert header_data1[12] = 535696487
    assert header_data1[13] = 2074190787
    assert header_data1[14] = 1410070449
    assert header_data1[15] = 3451258600
    assert header_data1[16] = 1461927438
    assert header_data1[17] = 1639736905
    assert header_data1[18] = 4294901789
    assert header_data1[19] = 31679129
    let (block_header1) = prepare_header(header_data1)
    %{
        print(f'version = {ids.block_header1.version:x}') 
        print('previous', list(map(hex, memory.get_range(ids.block_header1.previous, 4))))
        print('merkle', list(map(hex, memory.get_range(ids.block_header1.merkle_root, 4))))
        print(f'time = {ids.block_header1.time:x}')
        print(f'bits = {ids.block_header1.bits:x}')
        print(f'nonce = {ids.block_header1.nonce:x}')
    %}

    let (zero_hash : felt*) = alloc()
    assert zero_hash[0] = 0
    assert zero_hash[1] = 0
    assert zero_hash[2] = 0
    assert zero_hash[3] = 0

    let (block_hash0) = process_header(block_header0, zero_hash)
    let (block_hash1) = process_header(block_header1, block_hash0)

    return ()
end
