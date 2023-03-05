class ComponentPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    @model = model
  end

  def user_in_group_activities
    case @model.componentable.class.to_s
    when 'Archive'
      # same as in archive_policy
      at = ArchivizationType.joins(archivizations: {archive: [], group: { members: [:user]}})
        .where(archivizations: {archive: [@model.componentable], group: {members: {user_id: [@user]}}})
        .select(:activities).distinct.map(&:activities).flatten
      # puts '########################### at ################################'
      # puts at
      # puts '########################### at ################################'
      at
    when 'XXX'
      []
    end
  end

  def owner_access
    if @model.class.to_s == 'Symbol'
      false
    else
      # @model.user_id == @user.id || @model.componentable.user_id == @user.id
      @model.author_id == @user.id || @model.componentable.author_id == @user.id
    end
  end

  def archive_send_link_to_component_download?
    # moze osobne uprawnienie?
    # puts '--------------------------------------------------'
    # puts 'ComponentPolicy: archive_send_link_to_component_download?'
    # puts 'always TRUE'
    # puts '--------------------------------------------------'
    true    
  end

  def archive_send_link_to_component_download_simple?
    # moze osobne uprawnienie?
    # puts '--------------------------------------------------'
    # puts 'ComponentPolicy: archive_send_link_to_component_download_simple?'
    # puts 'always TRUE'
    # puts '--------------------------------------------------'
    true    
  end

  def archive_index?
    # puts '--------------------------------------------------'
    # puts 'ComponentPolicy: archive_index?'
    # puts '--------------------------------------------------'
    true
  end


  def archive_show?
    unless @model.componentable.is_expired?
      # classic
      user_activities.include?('archive:show') || (user_activities.include?('archive:show_self') && owner_access) || user_in_group_activities.include?('archive:show')
    else
      # expired
      user_activities.include?('archive:show_expiried') || (user_activities.include?('archive:show_expiried_self') && owner_access) || user_in_group_activities.include?('archive:show_expiried')
    end  
  end

  # def archive_show?
  #   user_activities.include?('archivization:show') || (user_activities.include?('archivization:self_show') && owner_access) || user_in_group_activities.include?('archivization:show')
  # end

  def archive_download?
    archive_show?
  end

  def archive_zip_and_download?
    # puts '--------------------------------------------------'
    # puts 'ComponentPolicy: archive_zip_and_download?'
    # puts '--------------------------------------------------'
#    user_activities.include?('archivization:show') || (user_activities.include?('archivization:self_show') && owner_access) || user_in_group_activities.include?('archivization:show')
    archive_show?
  end

  def archive_move_to_parent?
    archive_update?
  end


  def archive_create?
    user_activities.include?('archivization:create') || (user_activities.include?('archivization:self_create') && owner_access) || user_in_group_activities.include?('archivization:create')
  end

  def archive_edit?
    archive_update?
  end

  def archive_update?
    user_activities.include?('archivization:update') || (user_activities.include?('archivization:self_update') && owner_access) || user_in_group_activities.include?('archivization:update')
  end

  def archive_destroy?
    user_activities.include?('archivization:delete') || (user_activities.include?('archivization:self_delete') && owner_access) || user_in_group_activities.include?('archivization:delete')
  end

  def archive_work?
    # puts '--------------------------------------------------'
    # puts 'ComponentPolicy: archive_work?'
    # puts '--------------------------------------------------'
    true
  end


  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

end