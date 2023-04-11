class ArchivizationType < ApplicationRecord

  # relations
  has_many :archivizations, dependent: :nullify
  has_many :archives, through: :archivizations

  # validates
  validates :name, presence: true,
                    length: { in: 1..100 },
                    uniqueness: { case_sensitive: false }


  def self.for_user_more_privilage(user_has_more_privilage)
    (user_has_more_privilage == true) ? all : where(need_more_privilage: false)
  end

end
