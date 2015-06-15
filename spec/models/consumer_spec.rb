require 'rails_helper'
require 'shoulda/matchers'

describe Consumer, type: :model do
  subject() { FactoryGirl.create(:consumer) }
  it "should have a uuid" do
    should validate_presence_of(:uuid)
    should validate_uniqueness_of(:uuid)
  end
  it "should have a secret" do
    should validate_presence_of(:secret)
  end

  it 'should have a redirect_uri' do
    should validate_presence_of(:redirect_uri)
  end

  describe 'consumer.signed_token' do
    let (:user) { $user = FactoryGirl.create(:user) }
    let(:display_name) { $display_name = Faker::Name.name }
    let(:mail) { $mail = Faker::Internet.email }
    let(:scope) { $scope = 'email,uid,display_name' }
    let (:token) { $token = user.token(display_name: display_name, mail: mail, scope: scope) }
    let (:access_token) { $access_token = {access_token: token } }

    it 'should require a hash' do
      expect(subject).to respond_to 'signed_token'
      expect {
        subject.signed_token()
      }.to raise_error(ArgumentError)
    end

    it 'should take a token and returned a jason web token signed with the consumer secret' do
      jwt = subject.signed_token(access_token)
      decoded_access_token =   JWT.decode(jwt, subject.secret)[0]
      expect(decoded_access_token).to have_key('access_token')
      expect(decoded_access_token['access_token']).to eq(token)
    end
  end
end
