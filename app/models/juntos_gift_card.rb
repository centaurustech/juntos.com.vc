class JuntosGiftCard < ActiveRecord::Base
  belongs_to :default_gift_card
  belongs_to :gift_purchase
  belongs_to :project
  belongs_to :user

  scope :not_bought, -> { where(gift_purchase_id: nil) }

  validates :default_gift_card, :email, :user, :title, :description,
    :value, presence: true
  validates :email, format: { with: Devise.email_regexp }

  mount_uploader :image, JuntosGiftCardUploader
end
