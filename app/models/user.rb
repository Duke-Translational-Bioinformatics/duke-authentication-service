require 'securerandom'
class User < ActiveRecord::Base
  validates :uid, presence: true, uniqueness: true

  def token(**credentials)
    credentials.symbolize_keys!
    [:client_id, :email, :display_name, :scope].each do |rkey|
      unless credentials.has_key? rkey
        raise ArgumentError, "#{rkey} required"
      end
    end
    new_token = SecureRandom.hex
    credentials[:uid] = uid
    $redis.multi do
      $redis.set new_token, credentials.to_json
      $redis.expire new_token, Rails.application.config.token_ttl
    end
    new_token
  end

  def self.credentials(token)
    info = $redis.get(token)
    if info
      {
        info: info,
        expires_in: $redis.ttl(token)
      }
    end
  end
end
