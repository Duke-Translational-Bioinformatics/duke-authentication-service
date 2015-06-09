module DukeAuth
  class Base < Grape::API
    mount DukeAuth::V1::Base
  end
end
