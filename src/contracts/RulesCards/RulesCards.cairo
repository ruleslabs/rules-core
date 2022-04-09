%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

from models.metadata import Metadata
from models.card import Card, CardModel

# Libraries

from contracts.RulesCards.library import (
  RulesCards_card_model_available_supply,
  RulesCards_card_exists,
  RulesCards_rules_data,
  RulesCards_card_id,
  RulesCards_card,

  RulesCards_initializer,
  RulesCards_create_card,
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

from lib.roles.capper import (
  Capper_role,

  Capper_initializer,
  Capper_onlyCapper,
  Capper_grant,
  Capper_revoke
)

from lib.scarcity.Scarcity_base import (
  Scarcity_max_supply,
  Scarcity_productionStopped,

  Scarcity_addScarcity,
  Scarcity_stopProduction
)

# Constants

from openzeppelin.utils.constants import TRUE, FALSE

# Interfaces

from contracts.RulesData.IRulesData import IRulesData

#
# Constructor
#

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    bitwise_ptr: BitwiseBuiltin*,
    range_check_ptr
  }(owner: felt, _rules_data_address: felt):
  Ownable_initializer(owner)
  AccessControl_initializer(owner)
  Capper_initializer(owner)
  Minter_initializer(owner)

  RulesCards_initializer(_rules_data_address)
  return ()
end

#
# Getters
#

# Roles

@view
func CAPPER_ROLE{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (role: felt):
  let (role) = Capper_role()
  return (role)
end

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
func cardExists{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card_id: Uint256) -> (res: felt):
  let (exists) = RulesCards_card_exists(card_id)
  return (exists)
end

@view
func getCard{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card_id: Uint256) -> (card: Card, metadata: Metadata):
  let (card, metadata) = RulesCards_card(card_id)
  return (card, metadata)
end

@view
func getCardId{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    bitwise_ptr: BitwiseBuiltin*,
    range_check_ptr
  }(card: Card) -> (card_id: Uint256):
  let (card_id) = RulesCards_card_id(card)
  return (card_id)
end

# Supply

@view
func getSupplyForSeasonAndScarcity{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(season: felt, scarcity: felt) -> (supply: felt):
  let (supply) = Scarcity_max_supply(season, scarcity)
  return (supply)
end

@view
func productionStoppedForSeasonAndScarcity{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(season: felt, scarcity: felt) -> (stopped: felt):
  let (stopped) = Scarcity_productionStopped(season, scarcity)
  return (stopped)
end

@view
func getCardModelAvailableSupply{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(card_model: CardModel) -> (supply: felt):
  let (supply) = RulesCards_card_model_available_supply(card_model)
  return (supply)
end

# Other contracts

@view
func rulesData{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }() -> (address: felt):
  let (address) = RulesCards_rules_data()
  return (address)
end

#
# Externals
#

# Roles

@external
func addCapper{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(account: felt):
  Capper_grant(account)
  return ()
end

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
func revokeCapper{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(account: felt):
  Capper_revoke(account)
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

# Supply

@external
func addScarcityForSeason{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(season: felt, supply: felt) -> (scarcity: felt):
  Capper_onlyCapper()

  let (scarcity) = Scarcity_addScarcity(season, supply)
  return (scarcity)
end

@external
func stopProductionForSeasonAndScarcity{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
  }(season: felt, scarcity: felt):
  Capper_onlyCapper()

  Scarcity_stopProduction(season, scarcity)
  return ()
end

# Cards

@external
func createCard{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    bitwise_ptr: BitwiseBuiltin*,
    range_check_ptr
  }(card: Card, metadata: Metadata) -> (card_id: Uint256):
  Minter_only_minter()

  let (card_id) = RulesCards_create_card(card, metadata)
  return (card_id)
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
