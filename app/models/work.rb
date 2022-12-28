class Work < ApplicationRecord

  # relations
  belongs_to :author, class_name: "User", optional: true
  belongs_to :trackable, polymorphic: true, optional: true


  def pretty_parameters
    JSON.pretty_generate(JSON.parse(self.parameters.gsub('":"', '": "')))
  end

end
