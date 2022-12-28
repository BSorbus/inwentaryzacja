class User < ApplicationRecord

  USER_DEFAULT_FIRST_NAME = "nowy"
  USER_DEFAULT_LAST_NAME  = "użytkownik"
  USER_DEFAULT_USER_NAME  = "nowy użytkownik"

  include ActionView::Helpers::TextHelper # for truncate

  delegate :url_helpers, to: 'Rails.application.routes'

  devise :saml_authenticatable, :trackable


  # relations
  has_many :approvals, dependent: :destroy
  has_many :roles, through: :approvals

  has_many :members, dependent: :destroy
  has_many :groups, through: :members
  has_many :accesses_archives, through: :groups, source: :accesses_archives


  belongs_to :author, class_name: "User", optional: true
  has_many :works, as: :trackable

  # validates
  validates :user_name, presence: true,
                    length: { in: 1..100 }

  validates :email, presence: true,
                    length: { in: 1..100 },
                    uniqueness: { case_sensitive: false },
                    format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }

  validates :note, length: { in: 0..500 }
                    
  # callbacks
  before_validation :set_initial_data_corrected, on: :create
  after_commit :set_default_data, on: :create

  def set_default_data
    # if self.id != 1 # Jestśli to nie jest Administrator
    # role = Role.find(name: "Obserwator Składnic")
    # role = CreateRoleService.new.proposal_writer
    # self.roles << role 
    if author_id.blank?
      self.update_columns(author_id: id) 
    end
  end
  
  def log_work(action = '', action_user_id = nil)
    worker_id = action_user_id || self.author_id
    url = "<a href=#{url_helpers.user_path(self.id, locale: :pl)}>#{self.fullname}</a>".html_safe

    Work.create!(trackable_type: 'User', trackable_id: self.id, action: "#{action}", author_id: worker_id, url: "#{url}", 
      parameters: self.to_json(except: [:author_id], include: {author: {only: [:id, :user_name, :email]}}))
  end

  def name
    "#{first_name} #{last_name}"
  end

  def name_was
    "#{first_name_was} #{last_name_was}"
  end

  def fullname
    name.blank? ? "#{email}" : "#{email} (#{name})"
  end

  def fullname_was
    name_was.blank? ? "#{email_was}" : "#{email_was} (#{name_was})"
  end

  def last_name_to_display
    (last_name == USER_DEFAULT_LAST_NAME || last_name.blank?) ? "" : last_name    
  end

  def first_name_to_display
    (first_name == USER_DEFAULT_FIRST_NAME || first_name.blank?) ? "" : first_name    
  end

  def note_truncate
    truncate(Loofah.fragment(self.note).text, length: 100)
  end

  # Scope for select2: "user_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Eg.: "Jan ski@"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_user, ->(q) { where( create_sql_string("#{q}") ) }

  # Method create SQL query string for finder select2: "user_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Eg.: "Jan ski@"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #   Eg.: "((users.name ilike '%Jan%' OR users.email ilike '%Jan%') AND (users.name ilike '%ski@%' OR users.email ilike '%ski@%'))"
  #
  def self.create_sql_string(query_str)
    query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
  end

  # Method for glue parameters in create_sql_string
  # * parameters   :
  #   * +one_query_word+ -> word for search. 
  #   Eg.: "Jan"
  # * result   :
  #   * +sql_string+ -> SQL string query for one word 
  #   Eg.: "(users.name ilike '%Jan%' OR users.email ilike '%Jan%')"
  #
  def self.one_param_sql(one_query_word)
    #escaped_query_str = sanitize("%#{query_str}%")
    escaped_query_str = Loofah.fragment("'%#{one_query_word}%'").text
    "(" + %w(users.user_name users.first_name users.last_name users.email).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end

  private
  
    def set_initial_data_corrected
      self.email.downcase if self.email.present?
      
      self.first_name = USER_DEFAULT_FIRST_NAME if self.first_name.blank?
      self.last_name  = USER_DEFAULT_LAST_NAME  if self.last_name.blank?
      self.user_name  = USER_DEFAULT_USER_NAME  if self.user_name.blank?
    end 

end
