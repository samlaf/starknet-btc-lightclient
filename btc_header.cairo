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

func main():
    let (res) = prepare_header()
    return ()
end
