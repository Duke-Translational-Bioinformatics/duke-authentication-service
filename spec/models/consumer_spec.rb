require 'rails_helper'
require 'shoulda/matchers'

describe Consumer, type: :model do
  subject() { FactoryGirl.create(:consume) }
  it "should have a uuid" do
    should validate_presence_of(:uuid)
    should validate_uniqueness_of(:uuid)
  end
  it "shoud have a secret" do
    should validate_presence_of(:secret)
  end

  describe 'consumer.signed_token' do
    let (:user) { $user = FactoryGirl.create(:user) }
    let(:display_name) { $display_name = Faker::Name.name }
    let(:mail) { $mail = Faker::Internet.email }
    let(:scope) { $scope = 'email,uid,display_name' }
    let (:token) { $token = user.token(mail: mail, display_name: display_name, mail: mail, scope: scope) }
    let (:access_token) { $access_token = {access_token: token } }

    it 'should require a hash' do
      expect(consumer).to respond_to 'signed_token'
      expect {
        consumer.signed_token()
      }.to raise_error(ArgumentError)
    end

    it 'should take a token and returned a jason web token signed with the consumer secret' do
      jwt = consumer.signed_token(access_token)
      decoded_access_token =   JWT.decode(jwt, consumer.secret)[0]
      expect(decoded_access_token).to have_key('access_token')
      expect(decoded_access_token['access_token']).to eq(token)
    end
  end
end
