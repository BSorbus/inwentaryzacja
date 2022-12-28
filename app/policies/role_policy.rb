class RolePolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    @model = model
  end

  def index?
    user_activities.include?('role:index')
  end

  def show?
    user_activities.include?('role:show')
  end

  def new?
    create?
  end

  def create?
    user_activities.include?('role:create')
  end

  def edit?
    update?
  end

  def update?
    user_activities.include?('role:update')
  end

  def destroy?
    user_activities.include?('role:delete')
  end
 
  def work?
    user_activities.include?('role:work') || user_activities.include?('all:work')
  end

  def add_remove_role_user?
    user_activities.include?('role:add_remove_role_user')
  end
  
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end