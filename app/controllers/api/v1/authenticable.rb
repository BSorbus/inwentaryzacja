module Api
  module V1
    module Authenticable

      def token
        authenticate_with_http_basic do |username, password|
          system_for_api = ApiKey.find_by(name: username)
          if system_for_api && system_for_api.password == password
            render json: { token: system_for_api.access_token }, status: 200
          else
            render json: { error: 'Incorrect credentials' }, status: 401
          end
        end
      end

      def authenticate_system_from_token
        unless authenticate_with_http_token { |token, options| ApiKey.find_by(access_token: token) }
          render json: { error: 'Bad Token'}, status: 401
        end
      end

    end
  end
end