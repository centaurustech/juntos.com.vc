class DefaultGiftCard < ActiveRecord::Base
  belongs_to :gift_card_category

  validates :gift_card_category, :name, :title, :description, presence: true

  mount_uploader :image, JuntosGiftCardUploader
end
