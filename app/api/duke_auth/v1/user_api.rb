module DukeAuth
  module V1
    class UserAPI < Grape::API
      desc 'profile' do
        detail 'This allows a consumer to get a user profile'
        named 'profile'
        failure [404]
      end
      get '/profile/:id', root: false do
        
      end
    end
  end
end
