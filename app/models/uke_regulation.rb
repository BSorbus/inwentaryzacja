require 'net/http'

class UkeRegulation
	include ActiveModel::Model

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET, 
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
    Errno::ECONNREFUSED
  ]

  attr_accessor :response, :user_name, :api_key, :api_secret_key

  def initialize(params = {})
    @user_name = params.fetch(:user_name, '')
    @api_key = "#{Rails.application.secrets[:regulation_api_key]}"    
    @api_secret_key = "#{Rails.application.secrets[:regulation_api_secret_key]}"
  end

  def check_acceptance
    timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S") 

    uri = URI.parse("#{Rails.application.secrets[:regulation_api_url]}/api/verification/CheckAcceptance/#{@user_name}")
    request = Net::HTTP::Get.new(uri)
    request["X-Timestamp"] = timestamp
    request["X-Apikey"] = "#{@api_key}"
    request["Authorization"] = calculate_hmac(timestamp)

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

  rescue *HTTP_ERRORS => e
    Rails.logger.error('======== API ERROR "models/uke_regulation .check_acceptance"(1) =============')
    Rails.logger.error("#{e}")
    Rails.logger.error('=============================================================================')
    errors.add(:base, "API ERROR 'models/uke_regulation .check_acceptance(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('======== API ERROR "models/uke_regulation .check_acceptance"(2) =============')
    Rails.logger.error("#{e}")
    Rails.logger.error('=============================================================================')
    errors.add(:base, "API ERROR 'models/uke_regulation .check_acceptance(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('======== API ERROR "models/uke_regulation .check_acceptance"(3) ============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      errors.add(:base, "API ERROR 'models/uke_regulation .check_acceptance(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end


  def generate_acceptance_url
    safe_hash = calculate_hmac(@user_name).gsub('+', '_').gsub('/', '-')
    "#{Rails.application.secrets[:regulation_api_url]}/approval/?us=#{@user_name}&ak=#{@api_key}&hash=#{safe_hash}"    
  end

  def calculate_hmac(timestamp_or_username)
    secret_key_array = []
    secret_key_array << @api_secret_key     
    data = timestamp_or_username + @api_key
    digest = OpenSSL::Digest.new('sha256')
    hmac = OpenSSL::HMAC.digest(digest, secret_key_array.pack('H*'), data)
    Base64.encode64(hmac).chomp
  end

end
