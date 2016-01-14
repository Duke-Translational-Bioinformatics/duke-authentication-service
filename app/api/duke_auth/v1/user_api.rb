module DukeAuth
  module V1
    class UserAPI < Grape::API
      desc 'token_info' do
        detail 'This allows a consumer to validate a token and get a user profile'
        named 'token_info'
        failure [400]
      end
      params do
        optional :access_token, type: String
      end
      get '/token_info', root: false do
        token_info_params = declared(params, include_missing: false)
        if credentials = User.credentials(token_info_params[:access_token])
          info = JSON.parse(credentials[:info])
          audience = Consumer.where(uuid: info['client_id']).first
          signed_info = audience.signed_token({
            uid: info['uid'],
            first_name: info['first_name'],
            last_name: info['last_name'],
            display_name: info['display_name'],
            email: info['email'],
            service_id: Rails.application.secrets.service_id
          })
          {
            audience: audience.uuid,
            uid: info['uid'],
            scope: info['scope'],
            signed_info: signed_info,
            expires_in: credentials[:expires_in]
          }
        else
          error!({error: 'invalid_token'},400)
        end
      end

      desc 'revoke' do
        detail 'This allows a consumer to revoke a token'
        named 'revoke'
        failure [400]
      end
      params do
        requires :token, type: String
      end
      post '/revoke', root: false do
        $redis.del(params[:token])
        status 200
      end
    end
  end
end
