%builtins range_check bitwise

from sha256 import finalize_sha256, sha256
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

# Computes the SHA256 hash of the given input (up to 55 bytes).
# input should consist of a list of 32-bit integers (each representing 4 bytes, in big endian).
# n_bytes should be the number of input bytes (for example, it should be between 4*input_len - 3 and
# 4*input_len).
# Returns the 256 output bits as 2 128-bit big-endian integers.
func compute_sha256{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        input : felt*, n_bytes : felt) -> (res0 : felt, res1 : felt):
    alloc_locals

    let (local sha256_ptr_start : felt*) = alloc()
    let sha256_ptr = sha256_ptr_start

    let (local output : felt*) = sha256{sha256_ptr=sha256_ptr}(input, n_bytes)
    finalize_sha256(sha256_ptr_start=sha256_ptr_start, sha256_ptr_end=sha256_ptr)

    return (
        output[3] + 2 ** 32 * output[2] + 2 ** 64 * output[1] + 2 ** 96 * output[0],
        output[7] + 2 ** 32 * output[6] + 2 ** 64 * output[5] + 2 ** 96 * output[4])
end

struct IntArray32:
    member elements: felt*
    member word_len: felt # number of 64-bit words
    member byte_len: felt # total number of bytes
end

func main{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals

    local input : IntArray32

    %{
        from math import ceil
        from starkware.cairo.common.cairo_secp.secp_utils import split
        
        def pack_intarray32(base_addr, hex_input):
            elements = segments.add()
            for j in range(0, len(hex_input) // 8 + 1):
                hex_str = hex_input[j*8 : (j+1) * 8]
                if len(hex_str) > 0:
                    memory[elements + j] = int(hex_str, 16)
            memory[base_addr + ids.IntArray32.elements] = elements
            memory[base_addr + ids.IntArray32.word_len] = int(ceil(len(hex_input) / 2. / 8))
            memory[base_addr + ids.IntArray32.byte_len] = int(len(hex_input) / 2)

        # 16 byte preimage
        pack_intarray32(
            ids.input.address_,
            "19d6689c085ae165831e934ff763ae46")
     %}
    
    let (out1, out2) = compute_sha256(input.elements, input.byte_len)
    %{
        print(hex(ids.out1))
        print(hex(ids.out2))
    %}

    return ()
end
