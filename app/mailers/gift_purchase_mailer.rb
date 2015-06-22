class GiftPurchaseMailer < ActionMailer::Base
  default from: "from@example.com"

  def new_purchase(gift_id)
    @gift = JuntosGiftCard.find(gift_id)
    mail to: @gift.email, subject: @gift.title
  end
end
