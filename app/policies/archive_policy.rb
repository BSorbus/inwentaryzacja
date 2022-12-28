class ArchivePolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    @model = model
  end

  def permitted_attributes
    permitted_array = [:name, :expiry_on, :quota, :note]
    # if ArchivePolicy.new(@user, @model).add_remove_archive_group?
    #   permitted_array = [:name, :note, accessorizations_attributes: [:id, :event_id, :user_id, :role_id, :_destroy]]
    # else
    #   permitted_array = [:title, :all_day, :start_date, :end_date, :note, :project_id, :event_status_id, :event_type_id, :errand_id, :user_id]
    # end
    if @model.class.to_s == 'Symbol'
      permitted_array << [archivizations_attributes: [:id, :archives_id, :group_id, :archivization_type_id, :author_id, :_destroy]] if user_activities.include?('archive:add_remove_archive_group') || user_activities.include?('archive:add_remove_archive_group_self')
    else
      permitted_array << [archivizations_attributes: [:id, :archives_id, :group_id, :archivization_type_id, :author_id, :_destroy]] if ArchivePolicy.new(@user, @model).add_remove_archive_group?
    end
    permitted_array
  end

  def user_in_group_activities
    ArchivizationType.joins(archivizations: {archive: [], group: { members: [:user]}})
      .where(archivizations: {archive: [@model], group: {members: {user_id: [@user]}}})
      .select(:activities).distinct.map(&:activities).flatten
  end

  def user_in_any_group_activities
    ArchivizationType.joins(archivizations: {archive: [], group: { members: [:user]}})
      .where(archivizations: {group: {members: {user_id: [@user]}}})
      .select(:activities).distinct.map(&:activities).flatten
  end

  def owner_access
    if @model.class.to_s == 'Symbol'
      false
    else
      @model.author_id == @user.id
    end
  end

  def send_link_to_archive_show?
    # moze osobne uprawnienie?
    update?    
  end

  def index_in_role?
    user_activities.include?('archive:index')
  end

  def more_privilage_in_role?
    user_activities.include?('archive:more_privilage')
  end

  def index?
    user_activities.include?('archive:index') || user_in_any_group_activities.include?('archive:index')
  end

  def show?
    unless @model.is_expired?
      # classic
      user_activities.include?('archive:show') || (user_activities.include?('archive:show_self') && owner_access) || user_in_group_activities.include?('archive:show')
    else
      # expired
      user_activities.include?('archive:show_expiried') || (user_activities.include?('archive:show_expiried_self') && owner_access) || user_in_group_activities.include?('archive:show_expiried')
    end  
  end

  def new?
    create?
  end

  def create?
    user_activities.include? 'archive:create'
  end

  def edit?
    update?
  end

  def update?
    user_activities.include?('archive:update') || (user_activities.include?('archive:update_self') && owner_access) || user_in_group_activities.include?('archive:update')
  end

  def destroy?
    user_activities.include?('archive:delete') || (user_activities.include?('archive:delete_self') && owner_access) || user_in_group_activities.include?('archive:delete')
  end

  def work?
    user_activities.include?('archive:work') || user_in_group_activities.include?('archive:work')
  end

  def add_remove_archive_group?
    user_activities.include?('archive:add_remove_archive_group') || (user_activities.include?('archive:add_remove_archive_group_self') && owner_access) || user_in_group_activities.include?('archive:add_remove_archive_group')
  end
  
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
