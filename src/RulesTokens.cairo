%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.registers import get_fp_and_pc

from models.card import Card, Metadata

from token.ERC1155.ERC1155_base import (
  ERC1155_name,
  ERC1155_symbol,
  ERC1155_balanceOf,

  ERC1155_initializer,
  ERC1155_mint
)

from token.ERC1155.ERC1155_Metadata_base import (
  ERC1155_Metadata_tokenURI,
  ERC1155_Metadata_baseTokenURI,

  ERC1155_Metadata_setBaseTokenURI
)

from token.ERC1155.ERC1155_Supply_base import (
  ERC1155_Supply_exists,
  ERC1155_Supply_totalSupply,

  ERC1155_Supply_beforeTokenTransfer
)

from lib.Ownable_base import (
  Ownable_get_owner,

  Ownable_initializer,
  Ownable_only_owner,
  Ownable_transfer_ownership
)

from lib.roles.AccessControl_base import (
  AccessControl_hasRole,
  AccessControl_rolesCount,
  AccessControl_getRoleMember,

  AccessControl_initializer
)

from lib.roles.minter import (
  Minter_role,

  Minter_initializer,
  Minter_onlyMinter,
  Minter_grant,
  Minter_revoke
)

# Constants

from openzeppelin.utils.constants import TRUE, FALSE

#
# Import interfaces
#

from interfaces.IRulesCards import IRulesCards
# from interfaces.IRulesPacks import IRulesPacks

#
# Storage
#

@storage_var
func rules_cards_address_storage() -> (rules_cards_address: felt):
end

@storage_var
func rules_packs_address_storage() -> (rules_cards_address: felt):
end

#
# Events
#

@event
func Transfer(_from: felt, to: felt, token_id: Uint256, amount: Uint256):
end

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

  rules_cards_address_storage.write(_rules_cards_address)
  rules_packs_address_storage.write(_rules_packs_address)

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
  let (account) = AccessControl_getRoleMember(role, index)
  return (account)
end

@view
func getRoleMemberCount{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(role: felt) -> (count: felt):
  let (count) = AccessControl_rolesCount(role)
  return (count)
end

@view
func hasRole{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(role: felt, account: felt) -> (has_role: felt):
  let (has_role) = AccessControl_hasRole(role, account)
  return (has_role)
end

@view
func tokenURI{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(token_id: Uint256) -> (token_uri_len: felt, token_uri: felt*):
  let (token_uri_len, token_uri) = ERC1155_Metadata_tokenURI(token_id)
  return (token_uri_len, token_uri)
end

@view
func baseTokenURI{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (base_token_uri_len: felt, base_token_uri: felt*):
  let (base_token_uri_len, base_token_uri) = ERC1155_Metadata_baseTokenURI()
  return (base_token_uri_len, base_token_uri)
end

@view
func getCard{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card_id: Uint256) -> (card: Card, metadata: Metadata):
  let (rules_cards_address) = rules_cards_address_storage.read()

  let (card, metadata) = IRulesCards.getCard(rules_cards_address, card_id)
  return (card, metadata)
end

# Other contracts

@view
func rulesCards{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (address: felt):
  let (address) = rules_cards_address_storage.read()
  return (address)
end

@view
func rulesPacks{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (address: felt):
  let (address) = rules_packs_address_storage.read()
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
func tokenSupply{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(token_id: Uint256) -> (supply: Uint256):
  let (supply) = ERC1155_Supply_totalSupply(token_id)
  return (supply)
end

#
# Externals
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

@external
func createAndMintCard{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card: Card, metadata: Metadata, to: felt) -> (token_id: Uint256):
  alloc_locals

  Minter_onlyMinter()

  let (rules_cards_address) = rules_cards_address_storage.read()
  let (local card_id) = IRulesCards.createCard(rules_cards_address, card, metadata)

  _mint_token(to, token_id = card_id, amount = Uint256(1, 0))

  return (token_id = card_id)
end

@external
func mintCard{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card_id: Uint256, to: felt) -> (token_id: Uint256):

  Minter_onlyMinter()

  let (rules_cards_address) = rules_cards_address_storage.read()

  let (exists) = IRulesCards.cardExists(rules_cards_address, card_id)
  assert exists = TRUE # card doesn't exist

  let (exists) = ERC1155_Supply_exists(card_id)
  assert exists = FALSE # token already minted

  _mint_token(to, token_id = card_id, amount = Uint256(1, 0))

  return (token_id = card_id)
end

@external
func setBaseTokenURI{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(base_token_uri_len: felt, base_token_uri: felt*):

  Ownable_only_owner()

  ERC1155_Metadata_setBaseTokenURI(base_token_uri_len, base_token_uri)
  return ()
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

#
# Internals
#

func _mint_token{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(to: felt, token_id: Uint256, amount: Uint256):
  let (ids: Uint256*) = alloc()
  assert ids[0] = token_id

  let (amounts: Uint256*) = alloc()
  assert amounts[0] = amount

  ERC1155_Supply_beforeTokenTransfer(_from = 0, to = to, ids_len = 1, ids = ids, amounts = amounts)

  ERC1155_mint(to, token_id, amount)

  Transfer.emit(_from = 0, to = to, token_id = token_id, amount = amount)

  return ()
end
