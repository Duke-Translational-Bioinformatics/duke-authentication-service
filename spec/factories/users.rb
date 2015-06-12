FactoryGirl.define do
  factory :user do
    uid { "#{Faker::Name.name}#{Faker::Number.number(3)}" }
  end
end
