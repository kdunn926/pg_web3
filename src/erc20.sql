create type erc20_transfer_event
AS (
   event text,
   log_index int,
   transaction_index int,
   transaction_hash char(66),
   address char(42),
   block_hash char(66),
   block_number int
);

-- Wrapper for ERC-20 token transfer events (by token address, block number)

create or replace function web3_erc20_transers(arg_address text default '0xD850942eF8811f2A866692A623011bDE52a462C1', arg_start int default -1, arg_end int default -1, arg_provider text default 'https://mainnet.infura.io')
returns setof erc20_transfer_event
as $$

from web3 import Web3, HTTPProvider
from ethtoken.abi import EIP20_ABI

w3 = Web3(HTTPProvider(arg_provider))

contract = w3.eth.contract(address=Web3.toChecksumAddress(arg_address), abi=EIP20_ABI)

block_start = 'latest' if arg_start == -1 else arg_start
block_end = 'latest' if arg_end == -1 else arg_end

event_filter = contract.events.Transfer.createFilter(fromBlock=block_start, toBlock=block_end)

extract_fields = lambda r: (r.get('event'), 
                            r.get('logIndex'), 
                            r.get('transactionIndex'),
                            r.get('transactionHash').hex(), 
                            r.get('address'),
                            r.get('blockHash').hex(), 
                            r.get('blockNumber'))

return [extract_fields(r) for r in event_filter.get_all_entries()]

$$ language plpython3u volatile;

-- Wrapper for balanceOf.call(block)

create or replace function web3_erc20_balance(arg_address text default '0xD850942eF8811f2A866692A623011bDE52a462C1', arg_block int default -1, arg_provider text default 'https://mainnet.infura.io')
returns numeric
as $$

from web3 import Web3, HTTPProvider
from ethtoken.abi import EIP20_ABI

w3 = Web3(HTTPProvider(arg_provider))

contract = w3.eth.contract(address=Web3.toChecksumAddress(arg_address), abi=EIP20_ABI)

block = 'latest' if arg_block == -1 else arg_block

return contract.functions.balanceOf(Web3.toChecksumAddress(arg_address)).call(None, block)

$$ language plpython3u volatile;
