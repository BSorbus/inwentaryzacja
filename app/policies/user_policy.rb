class UserPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    @model = model
  end

  def index?
    user_activities.include?('user:index')
  end

  def show?
    user_activities.include?('user:show')
  end

  def new?
    create?
  end

  def create?
    user_activities.include?('user:create')
  end

  def edit?
    update?
  end

  def update?
    user_activities.include?('user:update')
  end

  def destroy?
    user_activities.include?('user:delete')
  end
 
  def work?
    user_activities.include?('user:work') || user_activities.include?('all:work')
  end
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end