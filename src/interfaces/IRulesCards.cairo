%lang starknet

from starkware.cairo.common.uint256 import Uint256

from models.card import Card, Metadata

@contract_interface
namespace IRulesCards:
  func getCard(card_id: Uint256) -> (card: Card, metadata: Metadata):
  end

  func createCard(card: Card, metadata: Metadata) -> (card_id: Uint256):
  end

  func cardExists(card_id: Uint256) -> (res: felt):
  end
end