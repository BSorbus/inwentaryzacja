# ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req| 
#   if req.env['rack.attack.match_type'] == :throttle 
#     Rails.logger.info "--------------------------------------------------" 
#     Rails.logger.info "Throttled IP: #{req.ip}" 
#     Rails.logger.info "--------------------------------------------------" 
#   end 
# end

ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, payload|

  req = payload[:request]
  attack_type = req.env['rack.attack.match_type']

  Rails.logger.info "------------------------------------------------------------------------------------" 
  Rails.logger.info "[Rack::Attack][#{attack_type}] remote_ip: #{req.remote_ip}"
  Rails.logger.info "[Rack::Attack] start: #{start}, finish: #{finish}"
  Rails.logger.info "[Rack::Attack] path: #{req.path}"
  Rails.logger.info "------------------------------------------------------------------------------------" 

  #AdminMailer.rack_attack_notification(name, start, finish, request_id, req.remote_ip, req.path, request_headers).deliver_later
end
