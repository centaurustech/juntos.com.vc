class JuntosGiftCardPolicy < ApplicationPolicy
  def index?
    user
  end

  def show?
    record.user == user
  end

  def new?
    record.user == user
  end

  def create?
    new?
  end

  def permitted_attributes
    %i(email user title description value default_gift_card_id project_id)
  end

  def edit_fields?
    record.default_gift_card
  end

  def destroy?
    user.juntos_gift_cards.not_bought.exists?(record)
  end

  class Scope #< Scope
    attr_accessor :user, :scope

    def initialize(user, scope)
      self.user = user
      self.scope = scope
    end

    def resolve
      scope.where(user: user)
    end
  end
end
