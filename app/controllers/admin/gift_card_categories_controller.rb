class Admin::GiftCardCategoriesController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i(index)

  def index
    authorize(GiftCardCategory)
    @categories = policy_scope(GiftCardCategory).page(params[:page])
  end

  def show
    @category = GiftCardCategory.find(params[:id])
    authorize(@category)
  end

  def new
    @category = GiftCardCategory.new
    authorize(@category)
  end

  def create
    @category = GiftCardCategory.new(permitted_params)
    authorize(@category)
    if @category.save
      redirect_to admin_gift_card_category_path(@category), notice: t('.success')
    else
      render :new
    end
  end

  def edit
    @category = GiftCardCategory.find(params[:id])
    authorize(@category)
  end

  def update
    @category = GiftCardCategory.find(params[:id])
    authorize(@category)
    if @category.update_attributes(permitted_params)
      redirect_to admin_gift_card_category_path(@category), notice: t('.sucess')
    else
      render :edit
    end
  end

  def destroy
    category = GiftCardCategory.find(params[:id])
    authorize(category)
    if category.destroy
      redirect_to admin_gift_card_categories_path, notice: t('.delete_error')
    else
      redirect_to admin_gift_card_categories_path(category), notice: t('.success')
    end
  end

  private

  def permitted_params
    attrs = policy(GiftCardCategory).permitted_attributes
    params.require(:gift_card_category).permit(*attrs)
  end
end
