require 'rails_helper'
require 'shoulda/matchers'

describe Consumer, type: :model do
  subject() { FactoryGirl.create(:consume) }
  it "should have a uuid" do
    should validate_presence_of(:uuid)
    should validate_uniqueness_of(:uuid)
  end
  it "should have a secret" do
    should validate_presence_of(:secret)
  end
end
