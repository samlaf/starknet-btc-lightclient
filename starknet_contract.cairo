%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

from btc_header import BTCHeader, process_header, prepare_header

@storage_var
func block_header_lo(number: felt) -> (hash_lo: felt):
end

@storage_var
func block_header_hi(number: felt) -> (hash_hi: felt):
end

@external
func process_block{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr}(
    height : felt,
    data_len : felt,
    data : felt*,
):
    #alloc_locals

    # Retrieve previous block header hash (or zero hash if genesis)
    let (prev_hash : felt*) = alloc()
    if height == 0:
        assert prev_hash[0] = 0
        assert prev_hash[1] = 0
        tempvar range_check_ptr=range_check_ptr
    else:
        let (lo) = block_header_lo.read(height - 1)
        let (hi) = block_header_hi.read(height - 1)
        assert prev_hash[0] = lo
        assert prev_hash[1] = hi
        tempvar range_check_ptr=range_check_ptr
    end

    # Verify provided block header
    let header = prepare_header(data)
    let block_hash = process_header(header, prev_hash)

    # Write current header to storage
    block_header_lo.write(height, block_hash[0])
    block_header_hi.write(height, block_hash[1])

    return ()
end
