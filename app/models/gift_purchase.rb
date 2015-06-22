class GiftPurchase < ActiveRecord::Base
  after_create :save_references_of_gifts
  attr_accessor :gift_cards

  belongs_to :user
  belongs_to :country

  has_many :juntos_gift_cards

  private

  def save_references_of_gifts
    gift_cards.update_all(gift_purchase_id: id) if gift_cards
  end
end
