source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use sqlite as the database for Active Record
gem 'sqlite3'
gem 'ruby-oci8'
gem 'activerecord-oracle_enhanced-adapter'

# Use puma as the webserver in development
gem 'puma'
gem 'rack-cors'

gem 'jwt'
gem 'grape'
gem "hashie-forbidden_attributes" #overrides strong_params in grape endpoints
gem "grape-active_model_serializers"
gem 'react-rails'
gem 'tilt'
gem 'jquery-rails'
gem 'turbolinks'
gem 'uglifier'
gem 'omniauth'
gem 'omniauth-shibboleth'

# use redis to cache the user temporarily
gem 'redis'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'spring'
  gem "factory_girl_rails"
  gem "faker"
  gem 'rspec-rails'
  gem 'shoulda-matchers', require: false
  gem 'spring-commands-rspec', group: :development
end

ruby "2.2.2"
