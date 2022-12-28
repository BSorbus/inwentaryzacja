class Approval < ApplicationRecord

  delegate :url_helpers, to: 'Rails.application.routes'


  # relations
  belongs_to :role
  belongs_to :user
  belongs_to :author, class_name: "User"


  def log_work_for_user(action = '', action_user_id = nil)
    worker_id = action_user_id || self.author_id
    url = "<a href=#{url_helpers.user_path(self.user.id, locale: :pl)}>#{self.user.fullname}</a>".html_safe

    Work.create!(trackable_type: 'User', trackable_id: self.user.id, action: "#{action}", author_id: worker_id, url: "#{url}",
      parameters: self.to_json(only: [:id, :created_at], include: {user: {only: [:id, :user_name, :email]}, 
                                                                   role: {only: [:id, :name]},
                                                                   author: {only: [:id, :user_name, :email]} }, root: 'approval' ))
  end

  def log_work_for_role(action = '', action_user_id = nil)
    worker_id = action_user_id || self.author_id
    url = "<a href=#{url_helpers.role_path(self.role.id, locale: :pl)}>#{self.role.fullname}</a>".html_safe

    Work.create!(trackable_type: 'Role', trackable_id: self.role.id, action: "#{action}", author_id: worker_id, url: "#{url}", 
      parameters: self.to_json(only: [:id, :created_at], include: {user: {only: [:id, :user_name, :email]}, 
                                                                   role: {only: [:id, :name]},
                                                                   author: {only: [:id, :user_name, :email]} }, root: 'approval'))
  end

end
