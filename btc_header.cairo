%builtins range_check bitwise
from starkware.cairo.common.alloc import alloc
from swap_endianness import swap_endianness_64
from sha256.sha256 import compute_sha256
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

# func get_header(
#        version : felt, previous : felt*, merkle_root : felt*, time : felt, bits : felt,
#        nonce : felt) -> (res : BTCHeader):
#    return (res=BTCHeader(version, previous, merkle_root, time, bits, nonce))
# end

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
    let time = data[17]
    let bits = data[18]
    let nonce = data[19]
    return (res=BTCHeader(version, previous, merkle_root, time, bits, nonce, data))
end

func process_header{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        header : Header, prev_header_hash : felt*):
    # TODO: Serialize header to bytes
    let (header_bytes) = serialize_header_to_bytes(header)

    # Check header length
    assert header_bytes.num_bytes = 80

    # TODO: Compute SHA256 of serialized header (big endian)
    # - Generalize 'compute_sha256' to inputs of at least 80 bytes
    # - Change output of 'compute_sha256' to 4 64-bit felts
    let (curr_header_hash) = compute_sha256(header_bytes, 80)

    # TODO: Verify previous block header with provided hash
    let (prev_hash_eq) = arr_eq(prev_header_hash, 4, curr_header_hash, 4)
    assert prev_hash_eq = 1

    # TODO: Verify difficulty target
    # - Convert SHA256 hash to Uint256 (see src/starkware/cairo/common/uint256.cairo)
    # - Parse bits into target and conert to Uint256
    # - Verify that hash > target using the 'uint256_le' function

    # TODO: Return current header hash
end

func main{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals
    let (data : felt*) = alloc()
    assert data[0] = 16777216
    assert data[1] = 0
    assert data[2] = 0
    assert data[3] = 0
    assert data[4] = 0
    assert data[5] = 0
    assert data[6] = 0
    assert data[7] = 0
    assert data[8] = 0
    assert data[9] = 1000599037
    assert data[10] = 2054886066
    assert data[11] = 2059873342
    assert data[12] = 1735823201
    assert data[13] = 2143820739
    assert data[14] = 2290766130
    assert data[15] = 983546026
    assert data[16] = 1260281418
    assert data[17] = 699096905
    assert data[18] = 4294901789
    assert data[19] = 497822588
    let (res) = prepare_header(data)
    %{
        print(f'version = {ids.res.version:x}') 
        print('previous', list(map(hex, memory.get_range(ids.res.previous, 4))))
        print('merkle', list(map(hex, memory.get_range(ids.res.merkle_root, 4))))
        print(f'time = {ids.res.time:x}')
        print(f'bits = {ids.res.bits:x}')
        print(f'nonce = {ids.res.nonce:x}')
    %}
    return ()
end
