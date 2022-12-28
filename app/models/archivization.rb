class Archivization < ApplicationRecord

  # relations
  belongs_to :archive, touch: true
  belongs_to :group
  belongs_to :archivization_type

  has_many :users, through: :group

  # validates
  # validates :group_id, presence: true,  
  #                     uniqueness: { scope: [:archive_id, :archivization_type_id], message: "jest już przypisana do tej Składnicy z takimi upprawnieniami" }  

  # validates :group_id, presence: true,  
  #                     uniqueness: { scope: [:archive_id, :archivization_type_id],  
  #                                   message: ->(object, data) do
  #                                     "'#{object.group.fullname}' z uprawnieniami '#{object.archivization_type.name}' jest już przypisana"
  #                                   end } 

  validates :group_id, presence: true,  
                      uniqueness: { scope: [:archive_id, :archivization_type_id],  
                                    message: ->(object, data) do
                                      I18n.t("activerecord.errors.messages.group_taken", group_name: "#{object.group.fullname}", archivization_type: "#{object.archivization_type.name}" )
                                    end } 

  # callbacks

end
