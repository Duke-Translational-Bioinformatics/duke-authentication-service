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
        error!({error: 'invalid_token'},400)
      end
    end
  end
end
