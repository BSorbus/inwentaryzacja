class WorkPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    #raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index?
    user_activities.include? 'all:work'
  end
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end