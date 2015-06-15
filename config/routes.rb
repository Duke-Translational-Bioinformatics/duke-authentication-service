Rails.application.routes.draw do
  mount DukeAuth::Base, at: '/'
end
