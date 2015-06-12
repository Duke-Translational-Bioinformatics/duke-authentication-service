require 'rails_helper'
require 'shoulda/matchers'

describe Consumer, type: :model do
  #pending "add some examples to (or delete) #{__FILE__}"
  it "has a uuid" do
    should validate_presence_of(:uuid)
    should validate_uniqueness_of(:uuid)
  end
  it "has a secret" do
    should validate_presence_of(:secret)
  end
end
