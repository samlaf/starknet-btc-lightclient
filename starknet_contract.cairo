%lang starknet

from btc_header import BTCHeader

@storage_var
func block_header_lo(number: felt) -> (hash_lo: felt):
end

@storage_var
func block_header_hi(number: felt) -> (hash_hi: felt):
end

@external
func process_block(
    version : felt,
    previous : felt*,
    merkle_root : felt*,
    time : felt,
    bits : felt,
    nonce : felt
) -> (res : BTCHeader):
    let header = BTCHeader(version, previous, merkle_root, time, bits, nonce)
    # TODO
    #let (block_hash0) = process_header(block_header0, zero_hash)
    #let (block_hash1) = process_header(block_header1, block_hash0)
end
