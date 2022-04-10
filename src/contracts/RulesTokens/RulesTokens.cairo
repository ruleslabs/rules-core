%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

from models.metadata import Metadata
from models.card import Card

# Libraries

from contracts.RulesTokens.library import (
  RulesTokens_token_uri,
  RulesTokens_card,
  RulesTokens_rules_cards,
  RulesTokens_rules_packs,

  RulesTokens_initializer,
  RulesTokens_create_and_mint_card,
  RulesTokens_mint_card,
  RulesTokens_mint_pack,
)

from token.ERC1155.ERC1155_base import (
  ERC1155_name,
  ERC1155_symbol,
  ERC1155_balanceOf,

  ERC1155_initializer,
)

from token.ERC1155.ERC1155_Metadata_base import (
  ERC1155_Metadata_base_token_uri,

  ERC1155_Metadata_set_base_token_uri
)

from token.ERC1155.ERC1155_Supply_base import (
  ERC1155_Supply_total_supply,
)

from lib.Ownable_base import (
  Ownable_get_owner,

  Ownable_initializer,
  Ownable_only_owner,
  Ownable_transfer_ownership
)

from lib.roles.AccessControl_base import (
  AccessControl_has_role,
  AccessControl_roles_count,
  AccessControl_role_member,

  AccessControl_initializer
)

from lib.roles.minter import (
  Minter_role,

  Minter_initializer,
  Minter_only_minter,
  Minter_grant,
  Minter_revoke
)

#
# Constructor
#

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(
    name: felt,
    symbol: felt,
    owner: felt,
    _rules_cards_address: felt,
    _rules_packs_address: felt,
  ):
  ERC1155_initializer(name, symbol)
  Ownable_initializer(owner)
  AccessControl_initializer(owner)
  Minter_initializer(owner)

  RulesTokens_initializer(_rules_cards_address, _rules_packs_address)
  return ()
end

#
# Getters
#

@view
func name{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (name: felt):
  let (name) = ERC1155_name()
  return (name)
end

@view
func symbol{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (symbol: felt):
  let (symbol) = ERC1155_symbol()
  return (symbol)
end

# Roles

@view
func MINTER_ROLE{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (role: felt):
  let (role) = Minter_role()
  return (role)
end

@view
func owner{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (owner: felt):
  let (owner) = Ownable_get_owner()
  return (owner)
end

@view
func getRoleMember{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(role: felt, index: felt) -> (account: felt):
  let (account) = AccessControl_role_member(role, index)
  return (account)
end

@view
func getRoleMemberCount{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(role: felt) -> (count: felt):
  let (count) = AccessControl_roles_count(role)
  return (count)
end

@view
func hasRole{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(role: felt, account: felt) -> (has_role: felt):
  let (has_role) = AccessControl_has_role(role, account)
  return (has_role)
end

@view
func tokenURI{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(token_id: Uint256) -> (token_uri_len: felt, token_uri: felt*):
  let (token_uri_len, token_uri) = RulesTokens_token_uri(token_id)
  return (token_uri_len, token_uri)
end

@view
func baseTokenURI{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (base_token_uri_len: felt, base_token_uri: felt*):
  let (base_token_uri_len, base_token_uri) = ERC1155_Metadata_base_token_uri()
  return (base_token_uri_len, base_token_uri)
end

@view
func getCard{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card_id: Uint256) -> (card: Card, metadata: Metadata):
  let (card, metadata) = RulesTokens_card(card_id)
  return (card, metadata)
end

# Other contracts

@view
func rulesCards{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (address: felt):
  let (address) = RulesTokens_rules_cards()
  return (address)
end

@view
func rulesPacks{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (address: felt):
  let (address) = RulesTokens_rules_packs()
  return (address)
end

# Balance and supply

@view
func balanceOf{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(account: felt, token_id: Uint256) -> (balance: Uint256):
  let (balance) = ERC1155_balanceOf(account, token_id)
  return (balance)
end

@view
func totalSupply{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(token_id: Uint256) -> (supply: Uint256):
  let (supply) = ERC1155_Supply_total_supply(token_id)
  return (supply)
end

#
# Setters
#

@external
func setBaseTokenURI{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(base_token_uri_len: felt, base_token_uri: felt*):
  Ownable_only_owner()
  ERC1155_Metadata_set_base_token_uri(base_token_uri_len, base_token_uri)
  return ()
end

#
# Business logic
#

# Roles

@external
func addMinter{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(account: felt):
  Minter_grant(account)
  return ()
end

@external
func revokeMinter{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(account: felt):
  Minter_revoke(account)
  return ()
end

# Cards

@external
func createAndMintCard{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card: Card, metadata: Metadata, to: felt) -> (token_id: Uint256):
  Minter_only_minter()
  let (token_id) = RulesTokens_create_and_mint_card(card, metadata, to)
  return (token_id)
end

@external
func mintCard{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card_id: Uint256, to: felt) -> (token_id: Uint256):
  Minter_only_minter()
  let (token_id) = RulesTokens_mint_card(card_id, to)
  return (token_id)
end

# Packs

@external
func mintPack{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(pack_id: Uint256, to: felt, amount: felt) -> (token_id: Uint256):
  Minter_only_minter()
  let (token_id) = RulesTokens_mint_pack(pack_id, to, amount)
  return (token_id)
end

# Ownership

@external
func transferOwnership{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(new_owner: felt) -> (new_owner: felt):
  Ownable_transfer_ownership(new_owner)
  return (new_owner)
end

@external
func renounceOwnership{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }():
  Ownable_transfer_ownership(0)
  return ()
end