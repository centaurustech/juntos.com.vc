class DefaultGiftCardPolicy < ApplicationPolicy
  def index?
    is_admin?
  end

  def show?
    is_admin?
  end

  def new?
    is_admin?
  end

  def create?
    new?
  end

  def edit
    is_admin?
  end

  def update
    edit?
  end

  def destroy?
    is_admin?
  end

  def permitted_attributes
    if is_admin?
      %i(gift_card_category_id name title description image image_cache)
    else
      []
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user && user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
