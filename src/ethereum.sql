create type ethereum_block
AS (
   difficulty bigint,
   extra_data text,
   gasLimit int,
   gasUsed int,
   hash char(66),
   logs_bloom text,
   miner text,
   mix_Hash char(66),
   nonce char(18),
   number int,
   parent_hash char(66),
   receipts_root char(66),
   sha3_uncles char(66),
   size int,
   state_root char(66),
   block_timestamp timestamp,
   total_difficulty numeric,
   transactions char(66)[]
);

-- Wrapper for web3.eth.getBlock(block_number)

create or replace function web3_ethereum_block(arg_block int default -1, arg_provider text default 'https://mainnet.infura.io')
returns ethereum_block
as $$

from web3 import Web3, HTTPProvider
import datetime as dt

w3 = Web3(HTTPProvider(arg_provider))

block = 'latest' if arg_block == -1 else arg_block

block_data = w3.eth.getBlock(block)

extract_fields = lambda r: (r.get('difficulty'), 
                            r.get('extraData').hex(), 
                            r.get('gasLimit'),
                            r.get('gasUsed'), 
                            r.get('hash').hex(),
                            r.get('logsBloom').hex(),
                            r.get('miner'),
                            r.get('mixHash').hex(), 
                            r.get('nonce').hex(),
                            r.get('number'), 
                            r.get('parentHash').hex(),
                            r.get('receiptsRoot').hex(), 
                            r.get('sha3Uncles').hex(),
                            r.get('size'),
                            r.get('stateRoot').hex(),
                            dt.datetime.utcfromtimestamp(r.get('timestamp')).isoformat(), 
                            r.get('totalDifficulty'),
                            [t.hex() for t in r.get('transactions')])

    
return extract_fields(block_data)

$$ language plpython3u volatile;


create type ethereum_transaction
AS (
   block_hash char(66),
   block_number int,
   sender_address char(42),
   gas int,
   gas_price numeric,
   transaction_hash char(66),
   input text,
   nonce int,
   r char(66),
   s char(66),
   receiver_address char(42),
   transaction_index int,
   v int,
   value numeric
);

-- Wrapper for web3.eth.getTransaction

create or replace function web3_ethereum_transaction(arg_transaction_hash text default '0xca6d2c69c7d6bbf8560e052eaff69b62cf66187d0a79a4b0940e551ebdf3be09', arg_provider text default 'https://mainnet.infura.io')
returns ethereum_transaction
as $$

from web3 import Web3, HTTPProvider
from ethtoken.abi import EIP20_ABI

w3 = Web3(HTTPProvider(arg_provider))

tx = w3.eth.getTransaction(arg_transaction_hash)

extract_fields = lambda r: (r.get('blockHash').hex(), 
                            r.get('blockNumber'), 
                            r.get('from'),
                            r.get('gas'), 
                            r.get('gasPrice'),
                            r.get('hash').hex(), 
                            r.get('input'), 
                            r.get('nonce'),
                            r.get('r').hex(), 
                            r.get('s').hex(),
                            r.get('to'),
                            r.get('transactionIndex'), 
                            r.get('v'),
                            r.get('value'))

return extract_fields(tx)

$$ language plpython3u volatile;
