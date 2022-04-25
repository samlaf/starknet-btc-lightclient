We use getblock to get blockhash, and then query the actual block. See https://getblock.io/docs/available-nodes-methods/BTC/JSON-RPC/getblockhash/

See https://en.bitcoin.it/wiki/Block_hashing_algorithm for block hashing algorithm

# Querying for blocks:
1. get an api-key by registering to getblock.io.
2. get the block hash of the block you want to query (here: 0)
```
curl --location --request POST 'https://btc.getblock.io/mainnet/' \                         (py39) 
      --header 'x-api-key: <API_KEY>' \
      --header 'Content-Type: application/json' \
      --data-raw '{"jsonrpc": "2.0",
  "method": "getblockhash",
  "params": [0],
  "id": "getblock.io"}'
```
3. get the block by hash
```
curl --location --request POST 'https://btc.getblock.io/mainnet/' \                         (py39) 
      --header 'x-api-key: <API_KEY>' \
      --header 'Content-Type: application/json' \
      --data-raw '{"jsonrpc": "2.0",
  "method": "getblock",
  "params": ["000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"],
  "id" : "getblock.io"}'
```