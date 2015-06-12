require 'securerandom'
class User < ActiveRecord::Base
  validates :uid, presence: true, uniqueness: true

  def token(**params)
    params.symbolize_keys!
    [:mail, :display_name, :scope].each do |rkey|
      unless params.has_key? rkey
        raise ArgumentError, "#{rkey} required"
      end
    end
    new_token = SecureRandom.hex
    credentials = {'uid': uid, 'mail': params[:mail], 'display_name': params[:display_name], 'scope': params[:scope]}.to_json
    $redis.multi do
      $redis.set new_token, credentials
      $redis.expire new_token, Rails.application.config.token_ttl
    end
    new_token
  end

  def self.credentials(token)
    $redis.get token
  end
end
