%lang starknet

from starkware.cairo.common.math import assert_le, assert_not_zero, unsigned_div_rem

from models.card import CardModel

# Constants

from openzeppelin.utils.constants import TRUE, FALSE

const CARDS_PER_PACK_MAX = 10

const CARDS_PER_PACK_MIN = 1

#
# Structs
#

struct PackCardModel:
  member card_model: CardModel
  member quantity: felt
end

#
# Functions
#

func get_pack_max_supply{
    range_check_ptr
  }(cards_per_pack: felt, pack_card_models_len: felt, pack_card_models: PackCardModel*) -> (max_supply: felt):
  alloc_locals

  _assert_pack_well_formed(cards_per_pack)

  let (local total) = _total_number_of_cards(pack_card_models_len, pack_card_models)
  let (quotient, remainder) = unsigned_div_rem(total, cards_per_pack)
  with_attr error_message("card models quantities and cards per pack are not compatible: {total} / {cards_per_pack}"):
    assert remainder = 0
  end

  return (quotient)
end

#
# Internals
#

func _assert_pack_well_formed{ range_check_ptr }(cards_per_pack: felt):
  assert_le(cards_per_pack, CARDS_PER_PACK_MAX)
  assert_le(CARDS_PER_PACK_MIN, cards_per_pack)

  return ()
end

func _total_number_of_cards(pack_card_models_len: felt, pack_card_models: PackCardModel*) -> (total: felt):
  if pack_card_models_len == 0:
    return (0)
  end

  # with_attr error_message("{[pack_card_models].quantity}, {pack_card_models_len}"):
  #   assert_le([pack_card_models].quantity, 20)
  # end

  let (total) = _total_number_of_cards(pack_card_models_len=pack_card_models_len - 1, pack_card_models=pack_card_models + PackCardModel.SIZE)
  return (total + [pack_card_models].quantity)
end