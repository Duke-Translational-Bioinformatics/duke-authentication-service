require 'faker'
require 'securerandom'

FactoryGirl.define do
  factory :consumer do
    uuid   { SecureRandom.uuid }
    secret { Faker::Lorem.characters }
  end

end
