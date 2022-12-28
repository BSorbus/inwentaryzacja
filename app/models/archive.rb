require 'my_human'

class Archive < ApplicationRecord
  include ActionView::Helpers::TextHelper

  QUOTA_SIZES = [["1,0 GB",    1000000000],
                 ["2,0 GB",    2000000000], 
                 ["3,0 GB",    3000000000], 
                 ["5,0 GB",    5000000000], 
                 ["10,0 GB",  10000000000], 
                 ["20,0 GB",  20000000000], 
                 ["30,0 GB",  30000000000], 
                 ["50,0 GB",  50000000000], 
                 ["100,0 GB",100000000000]]

  delegate :url_helpers, to: 'Rails.application.routes'


  # relations
  belongs_to :author, class_name: "User"

  has_many :archivizations, dependent: :destroy
  has_many :accesses_groups, through: :archivizations, source: :group
  has_many :accesses_users, through: :archivizations, source: :users

  has_many :components, as: :componentable, dependent: :destroy
  has_many :works, as: :trackable
 
  # validates
  validates :name, presence: true,
                    length: { in: 1..75 },
                    uniqueness: { case_sensitive: false }

  validates :note, length: { in: 0..500 }

  validate :expiry_on_after_today
  validates :expiry_on, presence: true

  validates :archivizations, presence: true
  validate :only_quota_resize_up, unless: -> { (new_record? == true) }

  # callbacks

  # additionals
  accepts_nested_attributes_for :archivizations, reject_if: :all_blank, allow_destroy: true


  def self.for_user_in_archivizations(u)
    eager_load(archivizations: [group: :users])
      .where( archivizations: {groups: {members: {user_id: [u]} } } )  
  end

  def log_work(action = '', action_user_id = nil)
    worker_id = action_user_id || self.author_id
    url = "<a href=#{url_helpers.archive_path(self.id, locale: :pl)}>#{self.fullname}</a>".html_safe

    Work.create!(trackable_type: 'Archive', trackable_id: self.id, action: "#{action}", author_id: worker_id, url: "#{url}", 
      parameters: self.to_json(except: [:author_id], include: {archivizations: {only: [:id], include: { group: {only: [:id, :name]}, 
                                                                                                      archivization_type: {only: [:id, :name]}} }, 
                  author: {only: [:id, :user_name, :email]}}
      )
    )
  end


  def log_work_send_email(action = '', action_user_id = nil, recipients = nil)
    worker_id = action_user_id || self.author_id

    # puts recipients.class         #Mail::AddressContainer
    # puts recipients.first         #jan.kowalski@email.com
    # puts recipients.first.class   #String

    recipient = User.find_by(email: recipients.first)
    recipient_str = recipient.to_json(only: [:id, :user_name, :first_name, :last_name, :email], include: {author: {only: [:id, :user_name, :email]}}, root: 'recipient')
    recipient_hash = JSON.parse(recipient_str)
 
    archive_str = self.to_json( except: [:author_id], include: {author: {only: [:id, :user_name, :email]} }, root: 'archive' )
    archive_hash = JSON.parse(archive_str)

    # save for Archive Object
    archive_with_recipient_hash = archive_hash.merge(recipient_hash)
    archive_with_recipient_json = archive_with_recipient_hash.to_json 

    # url_archive = eval( "url_helpers.link_to( #{self.fullname}, archive_path(#{self.id}, locale: :pl), remote: false)")
    url_archive = "<a href=#{url_helpers.archive_path(self.id, locale: :pl)}>#{self.fullname}</a>".html_safe
    Work.create!(trackable_type: 'Archive', trackable_id: self.id, action: "#{action}", author_id: worker_id, url: "#{url_archive}", parameters: archive_with_recipient_json)

    # save for User Object
    recipient_with_archive_hash = recipient_hash.merge(archive_hash)
    recipient_with_archive_json = recipient_with_archive_hash.to_json 

    # url_user = eval( "url_helpers.link_to( #{self.fullname}, user_path(#{recipient.id}, locale: :pl), remote: false)")
    url_user = "<a href=#{url_helpers.user_path(recipient.id, locale: :pl)}>#{recipient.fullname}</a>".html_safe
    Work.create!(trackable_type: 'User', trackable_id: recipient.id, action: "#{action}", author_id: worker_id, url: "#{url_user}", parameters: recipient_with_archive_json)

  end


  def fullname
    "#{name}"
  end

  def fullname_was
    "#{name_was}"
  end

  def note_truncate
    truncate(Loofah.fragment(self.note).text, length: 250)
  end


  def is_expired?
    today = Time.zone.today
    if expiry_on >= today
      false
    else
      true
    end  
  end

  private
  
    def expiry_on_after_today
      return if expiry_on.blank?
     
      if is_expired?
        errors.add(:expiry_on, I18n.t('errors.messages.greater_than_or_equal_to', count: Time.zone.today.strftime('%Y-%m-%d')  ) ) 
        throw :abort 
      end 
    end

    def only_quota_resize_up
      if quota < quota_was
        errors.add(:quota, I18n.t('errors.messages.greater_than_or_equal_to', count: MyHuman.new.filesize(quota_was) )) 
        throw :abort 
      end 
    end

end