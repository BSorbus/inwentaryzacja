require 'my_human'

class Component < ApplicationRecord
  include ActionView::Helpers::TextHelper
  include  ActionView::Helpers::NumberHelper

  delegate :url_helpers, to: 'Rails.application.routes'


  # relations
  belongs_to :author, class_name: "User"
  belongs_to :componentable, polymorphic: true

  has_many :works, as: :trackable

  # validates
  # validates :name, presence: true,
  #                  length: { in: 1..100 },
  #                  uniqueness: { case_sensitive: false, scope: [:componentable_id, :componentable_type, :parent_id], message: " - istnieje objekt o takiej nazwie (%{value})" }, allow_blank: true

  validates :name, presence: true,
                   length: { in: 1..100 },
                   uniqueness: { case_sensitive: false, scope: [:componentable_id, :componentable_type, :parent_id] }, allow_blank: true

  validates :component_file, presence: true, 
                    file_content_type: { exclude: [ 'application/x-msdos-program',
                                                    'application/cmd',
                                                    'application/x-ms-dos-executable',
                                                    'application/x-msdownload',
                                                    'application/x-javascript', 
                                                    'application/x-msi',
                                                    'application/x-php',
                                                    'application/x-python',
                                                    'application/x-vbs' ] },
                    file_size: { in: 1.byte..2.gigabyte }, unless: -> { name_if_folder.present? }

  validate :check_quota, on: :create, unless: -> { name_if_folder.present? }

  # callbacks
  before_validation :set_name_corrected

  # carrierwave uploader
  mount_uploader :component_file, ComponentUploader

  has_closure_tree dependent: :destroy, touch: true
  

  def self.only_for_parent(parent_id)
    where(parent_id: parent_id)
  end

  def is_file?
    component_file.present?
  end

  def is_folder?
    !is_file?
  end

  def log_work(action = '', action_user_id = nil)
    worker_id = action_user_id || self.user_id

    archive_str = self.componentable.to_json(except: [:author_id], include: {author: {only: [:id, :user_name, :email]}}, root: 'archive' )
    archive_hash = JSON.parse(archive_str)
 
    component_str = self.to_json( except: [:author_id], include: {author: {only: [:id, :user_name, :email]} }, root: 'component' )
    component_hash = JSON.parse(component_str)

    # save for Archive Object
    archive_with_component_hash = archive_hash.merge(component_hash)
    archive_with_component_json = archive_with_component_hash.to_json 

    url_archive = "<a href=#{url_helpers.archive_path(self.componentable.id, locale: :pl)}>#{self.componentable.fullname}</a>".html_safe
    Work.create!(trackable_type: 'Archive', trackable_id: self.componentable.id, action: "#{action}", author_id: worker_id, url: "#{url_archive}", parameters: archive_with_component_json)

    # save for User Object
    user = User.find(worker_id)
    Work.create!(trackable_type: 'User', trackable_id: user.id, action: "#{action}", author_id: worker_id, url: "#{url_archive}", parameters: archive_with_component_json)

  end

  def log_work_send_email(action = '', action_user_id = nil, recipients = nil)
    worker_id = action_user_id || self.author_id

    # puts recipients.class         #Mail::AddressContainer
    # puts recipients.first         #jan.kowalski@email.com
    # puts recipients.first.class   #String

    recipient = User.find_by(email: recipients.first)
    recipient_str = recipient.to_json(only: [:id, :user_name, :first_name, :last_name, :email], include: {author: {only: [:id, :user_name, :email]}}, root: 'recipient')
    recipient_hash = JSON.parse(recipient_str)
 
    component_str = self.to_json( except: [:author_id], include: {author: {only: [:id, :user_name, :email]}, componentable: {only: [:id, :name]} }, root: 'component')
    component_hash = JSON.parse(component_str)


    # save for Archive Object
    component_with_recipient_hash = component_hash.merge(recipient_hash)
    component_with_recipient_json = component_with_recipient_hash.to_json 

    # url_archive = eval( "url_helpers.link_to( #{self.fullname}, archive_path(#{self.id}, locale: :pl), remote: false)")
    url_archive = "<a href=#{url_helpers.archive_path(self.componentable.id, locale: :pl)}>#{self.componentable.fullname}</a>".html_safe
    Work.create!(trackable_type: 'Archive', trackable_id: self.componentable.id, action: "#{action}", author_id: worker_id, url: "#{url_archive}", parameters: component_with_recipient_json)

    # save for User Object
    recipient_with_component_hash = recipient_hash.merge(component_hash)
    recipient_with_component_json = recipient_with_component_hash.to_json 

    # url_user = eval( "url_helpers.link_to( #{self.fullname}, user_path(#{recipient.id}, locale: :pl), remote: false)")
    url_user = "<a href=#{url_helpers.user_path(recipient.id, locale: :pl)}>#{recipient.fullname}</a>".html_safe
    Work.create!(trackable_type: 'User', trackable_id: recipient.id, action: "#{action}", author_id: worker_id, url: "#{url_user}", parameters: recipient_with_component_json)

  end

  def destroy_and_log_work(current_user_id)
    destroyed_clone = self.clone
    destroyed_return = self.destroy
    if destroyed_return
      destroyed_clone.log_work('destroy_component', current_user_id)
    end
    return destroyed_return
  end

  def self.move_to_parent_and_log_work(parent, children, current_user_id)
    errors_array = []
    parent = nil if ( parent.blank? || parent == 'null' || parent == '' || parent == 0 )

    ApplicationRecord.transaction do
      children.each do |child_id|
        child = Component.find(child_id)
        if child.parent_id != parent 
          update_ok = child.update(parent_id: parent, author_id: current_user_id)
          if update_ok
            child.log_work('move_attachment', current_user_id)
          else
            errors_array << child.errors 
          end
        end
      end
    end

    return errors_array
  end

  def fullname
    # "#{self.attached_file_identifier}"
    "#{self.name}"
  end

  def note_truncate
    truncate(Loofah.fragment(self.note).text, length: 50)
  end

  private
  
    def set_name_corrected
      if self.name_if_folder.present?
        self.name = self.name_if_folder
      else 
        self.name = self.component_file.present? ? self.component_file.file.filename : nil
      end
    end 

    def check_quota
      sum_files_size = self.componentable.components.where.not(component_file: nil).map {|a| a.component_file.file.size }.sum
      current_file_size = component_file.file.size 
      archive_quota = self.componentable.quota
      if sum_files_size + current_file_size > archive_quota
        # errors.add(:sum_file_size, I18n.t('errors.messages.less_than', count: number_to_human_size(archive_quota)) ) 
        errors.add(:sum_file_size, I18n.t('errors.messages.less_than', count: MyHuman.new.filesize(archive_quota)) ) 
        throw :abort 
      end 
    end

end
