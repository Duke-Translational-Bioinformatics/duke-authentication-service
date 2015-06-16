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
          {
            audience: info['client_id'],
            uid: info['uid'],
            scope: info['scope'],
            expires_in: credentials[:expires_in]
          }
        else
          error!({error: 'invalid_token'},400)
        end
      end
    end
  end
end
