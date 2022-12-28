require 'ipaddr'

class Rack::Attack

  class Request < ::Rack::Request

    def remote_ip
      @remote_ip ||= (env['action_dispatch.remote_ip'] || ip).to_s
    end

    def allowed_ip?
      allowed_ips = ["127.0.0.1", "::1"]
      allowed_ips.include?(remote_ip)
    end

  end

  # safelist('allow from localhost') do |req|
  #   req.allowed_ip?
  # end

  # blocklist("fail2ban") do |req|
  #   Rack::Attack::Fail2Ban.filter("fail2ban-#{req.remote_ip}", maxretry: 1, findtime: 1.day, bantime: 1.day) do
  #     CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
  #       req.path.include?("/etc/passwd") ||
  #       req.path.include?("wp-admin") ||
  #       req.path.include?("wp-login") ||
  #       /\S+\.php/.match?(req.path)
  #   end
  # end

  # # Lockout IP addresses that are hammering your login page.
  # # After 20 requests in 1 minute, block all requests from that IP for 1 hour.
  # Rack::Attack.blocklist('allow2ban login scrapers') do |req|
  #   # `filter` returns false value if request is to your login page (but still
  #   # increments the count) so request below the limit are not blocked until
  #   # they hit the limit.  At that point, filter will return true and block.
  #   Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 5, findtime: 1.minute, bantime: 1.minutes) do
  #     # The count for the IP is incremented if the return value is truthy.
  #     req.path == '/en/static_pages/home' #and req.post?
  #   end
  # end


  # throttle("limit logins per email", limit: 30, period: 30.seconds) do |req|
  #   if req.path == "/users/sign_in" && req.post?
  #     if (req.params["user"].to_s.size > 0) and (req.params["user"]["email"].to_s.size > 0)
  #       req.params["user"]["email"]
  #     end
  #   end
  # end

  # throttle("limit signups", limit: 30, period: 30.seconds) do |req|
  #   req.remote_ip if req.path == "/users" && req.post?
  # end

  # # Exponential backoff for all requests to "/" path
  # #
  # # Allows 240 requests/IP in ~8 minutes
  # #        480 requests/IP in ~1 hour
  # #        960 requests/IP in ~8 hours (~2,880 requests/day)
  # (3..5).each do |level|
  #   throttle("req/ip/#{level}",
  #              limit: (30 * (2 ** level)),
  #              period: (0.9 * (8 ** level)).to_i.seconds) do |req|
  #     req.remote_ip # unless req.path.starts_with?('/assets')
  #   end
  # end
end

