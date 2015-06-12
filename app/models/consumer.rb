class Consumer < ActiveRecord::Base
  validates :uuid, presence: true, uniqueness: true
  validates :secret, presence: true
end
