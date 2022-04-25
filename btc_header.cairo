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
end

func get_header(
        version : felt, previous : felt*, merkle_root : felt*, time : felt, bits : felt,
        nonce : felt) -> (res : BTCHeader):
    return (res=BTCHeader(version, previous, merkle_root, time, bits, nonce))
end

func prepare_header(data : felt*) -> (res: felt*):
    return (res=[0,1,2,3,4])
end

func process_header{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        header: Header,
        prev_header_hash: felt*):
    # TODO: Serialize header to bytes
    let (header_bytes) = serialize_header_to_bytes(header)

    # Check header length
    assert header_bytes.num_bytes = 80

    # TODO: Compute SHA256 of serialized header (big endian)
    # 		- Generalize 'compute_sha256' to inputs of at least 80 bytes
    # 		- Change output of 'compute_sha256' to 4 64-bit felts 
    let (curr_header_hash) = compute_sha256(header_bytes, 80)

    # TODO: Verify previous block header with provided hash
    let (prev_hash_eq) = arr_eq(prev_header_hash, 4, curr_header_hash, 4)
    assert prev_hash_eq = 1

    # TODO: Verify difficulty target
    # 		- Convert SHA256 hash to Uint256 (see src/starkware/cairo/common/uint256.cairo)
    #       - Parse bits into target and conert to Uint256
    # 		- Verify that hash > target using the 'uint256_le' function

    # TODO: Return current header hash
end

func main():
    let (res) = prepare_header()
    return ()
end
