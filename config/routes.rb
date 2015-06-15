Rails.application.routes.draw do
  get :authenticate, to: 'authentication#authenticate'
  get '/auth/shibboleth/callback', to: 'authentication#handle_shibboleth', as: 'shibboleth_login'
  get 'authorize', to: 'authentication#authorize', as: 'authorize'
  post 'process_authorization', to: 'authentication#process_authorization'
end
