class Admin::DefaultGiftCardsController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i(index)

  def index
    authorize(DefaultGiftCard)
    @cards = policy_scope(DefaultGiftCard).page(params[:page])
  end

  def show
    @card = DefaultGiftCard.find(params[:id])
    authorize(@card)
  end

  def new
    @card = DefaultGiftCard.new
    authorize(@card)
  end

  def create
    @card = DefaultGiftCard.new(permitted_params)
    authorize(@card)
    if @card.save
      redirect_to admin_default_gift_card_path(@card), notice: t('.success')
    else
      render :new
    end
  end

  def edit
    @card = DefaultGiftCard.find(params[:id])
    authorize(@card)
  end

  def update
    @card = DefaultGiftCard.find(params[:id])
    authorize(@card)
    if @card.update_attributes(permitted_params)
      redirect_to admin_default_gift_card_path(@card), notice: t('.sucess')
    else
      render :edit
    end
  end

  def destroy
    card = DefaultGiftCard.find(params[:id])
    authorize(card)
    if card.destroy
      redirect_to admin_default_gift_cards_path, notice: t('.success')
    else
      redirect_to admin_default_gift_card_path(card), notice: t('.delete_error')
    end
  end

  private

  def permitted_params
    attrs = policy(DefaultGiftCard).permitted_attributes
    params.require(:default_gift_card).permit(*attrs)
  end
end
