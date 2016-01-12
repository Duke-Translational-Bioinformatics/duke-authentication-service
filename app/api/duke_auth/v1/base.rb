module DukeAuth
  module V1
    class Base < Grape::API
      version 'v1', using: :path
      content_type :json, 'application/json'
      default_format :json
      formatter :json, Grape::Formatter::ActiveModelSerializers
      prefix :api
      do_not_route_options!
      do_not_route_head!

      helpers do
        def logger
          Rails.logger
        end
      end

      rescue_from Grape::Exceptions::ValidationErrors do |e|
          error_payload = { 
            error: 'invalid_request',
            error_description: e.message 
          }
          error!(error_payload, 400)
      end

      mount DukeAuth::V1::UserAPI
      mount DukeAuth::V1::AppAPI
    end
  end
end
