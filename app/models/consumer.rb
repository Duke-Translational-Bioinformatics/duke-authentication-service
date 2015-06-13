class Consumer < ActiveRecord::Base
  validates :uuid, presence: true, uniqueness: true
  validates :secret, presence: true

  def signed_token(token)
    JWT.encode(token, secret)
  end
end
