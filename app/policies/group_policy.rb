class GroupPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    @model = model
  end

  def index?
    user_activities.include?('group:index')
  end

  def show?
    user_activities.include?('group:show')
  end

  def new?
    create?
  end

  def create?
    user_activities.include?('group:create')
  end

  def edit?
    update?
  end

  def update?
    user_activities.include?('group:update')
  end

  def destroy?
    user_activities.include?('group:delete')
  end
 
  def work?
    user_activities.include?('group:work') || user_activities.include?('all:work')
  end

  def add_remove_group_user?
    user_activities.include?('group:add_remove_group_user')
  end
  
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end