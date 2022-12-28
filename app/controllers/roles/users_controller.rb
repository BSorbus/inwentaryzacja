class Roles::UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def create
    role = Role.find(params[:role_id])
    user = User.find(params[:id])

    authorize role, :add_remove_role_user? 

    approval = Approval.create!(role: role, user: user, author: current_user)
    approval.log_work_for_user('add_role_to_user', current_user.id)
    approval.log_work_for_role('add_user_to_role', current_user.id)

    head :ok
  end

  def destroy
    role = Role.find(params[:role_id])
    user = User.find(params[:id])

    authorize role, :add_remove_role_user? 

    if role.present? && user.present?
      approval = Approval.find_by(role: role, user: user)
      destroyed_clone = approval.clone
      if approval.destroy
        destroyed_clone.log_work_for_user('remove_role_from_user', current_user.id)
        destroyed_clone.log_work_for_role('remove_user_from_role', current_user.id)
      end
    end

    head :no_content
  end

end
