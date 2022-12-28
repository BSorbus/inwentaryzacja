class Groups::UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def create
    group = Group.find(params[:group_id])
    user = User.find(params[:id])

    authorize group, :add_remove_group_user? 

    member = Member.create!(group: group, user: user, author: current_user)
    member.log_work_for_user('add_group_to_user', current_user.id)
    member.log_work_for_group('add_user_to_group', current_user.id)

    head :ok
  end

  def destroy
    group = Group.find(params[:group_id])
    user = User.find(params[:id])

    authorize group, :add_remove_group_user? 

    if group.present? && user.present?
      member = Member.find_by(group: group, user: user)
      destroyed_clone = member.clone
      if member.destroy
        destroyed_clone.log_work_for_user('remove_group_from_user', current_user.id)
        destroyed_clone.log_work_for_group('remove_user_from_group', current_user.id)
      end
    end

    head :no_content
  end

end
