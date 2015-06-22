class JuntosGiftCardsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i(index)

  def index
    authorize(JuntosGiftCard)
    @cards = policy_scope(JuntosGiftCard).page(params[:page])
    @cards_in_cart = policy_scope(JuntosGiftCard).not_bought
  end

  def show
    @card = JuntosGiftCard.find(params[:id])
    authorize(@card)
  end

  def new
    @card = current_user.juntos_gift_cards.new
    @card.default_gift_card_id = params[:default_card]
    authorize(@card)
    @card.title = @card.default_gift_card.try(:title)
    @card.description = @card.default_gift_card.try(:description)
    @defaults_cards = DefaultGiftCard.all
  end

  def create
    @card = current_user.juntos_gift_cards.new(permitted_params)
    authorize(@card)

    if @card.default_gift_card.image.class.storage == CarrierWave::Storage::File
      @card.image = @card.default_gift_card.image.file
    else
      @card.remote_image_url = @card.default_gift_card.image.url
    end

    if @card.save
      redirect_to juntos_gift_card_path(@card), notice: 'Sucesso'
    else
      render :new
    end
  end

  def destroy
    @card = current_user.juntos_gift_cards.find(params[:id])
    authorize(@card)
    @card.destroy
    redirect_to juntos_gift_cards_path, notice: 'Removido com sucesso'
  end

  private

  def permitted_params
    attrs = policy(JuntosGiftCard).permitted_attributes
    params.require(:juntos_gift_card).permit(*attrs)
  end
end
