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
    let (:user) { FactoryGirl.create(:user) }
    let (:first_name) { Faker::Name.first_name }
    let (:last_name) { Faker::Name.last_name }
    let(:display_name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:scope) { Rails.application.config.default_scope }
    let (:token) { user.token(
        client_id: subject.uuid,
        first_name: first_name,
        last_name: last_name,
        display_name: display_name,
        email: email,
        scope: scope
      )
    }
    let (:access_token) { { access_token: token } }

    it 'should require a hash' do
      expect(subject).to respond_to 'signed_token'
      expect {
        subject.signed_token()
      }.to raise_error(ArgumentError)
      expect {
        subject.signed_token(access_token)
      }.not_to raise_error
    end

    it 'should take a hash, add its uuid as the client_id, and returned a jason web token signed with the consumer secret' do
      jwt = subject.signed_token(access_token)
      decoded_access_token =   JWT.decode(jwt, subject.secret)[0]
      expect(decoded_access_token).to have_key('access_token')
      expect(decoded_access_token['access_token']).to eq(token)
      expect(decoded_access_token).to have_key('client_id')
      expect(decoded_access_token['client_id']).to eq(subject.uuid)
    end
  end
end
