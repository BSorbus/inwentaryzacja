class ApiKey < ApplicationRecord

  validates :name, presence: true,
                    length: { in: 1..30 },
                    uniqueness: { case_sensitive: false }

  before_create :generate_password_and_access_token
  

	def encode64_name_and_pass
		Base64.encode64("#{self.name}:#{self.password}")
	end

	private
	  
	  def generate_password_and_access_token
	    begin
	      self.password = SecureRandom.hex.encode('utf-8')
	      self.access_token = SecureRandom.hex.encode('utf-8')
	    end 
	  end

end
