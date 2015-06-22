class GiftPurchasePolicy < ApplicationPolicy
  def index?
    user
  end

  def show?
    user && record.user == user
  end

  def new?
    user
  end

  def create?
    new?
  end

  def add_to_cart?
    new?
  end

  def remove_from_cart?
    new?
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
