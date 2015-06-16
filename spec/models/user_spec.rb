require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe User, type: :model do
  subject { FactoryGirl.create(:user) }
  let(:display_name) { Faker::Name.name }
  let(:mail) { Faker::Internet.email }
  let(:scope) { Rails.application.config.default_scope }
  let(:min_secs) { 3 * 60 * 60 }
  let(:full_expire) { 4 * 60 * 60 }
  let(:consumer) { FactoryGirl.create(:consumer) }
  let(:expected_credentials) { {
      uid: subject.uid,
      client_id: consumer.uuid,
      mail: mail,
      display_name: display_name,
      scope: scope
    }
  }

  after(:all) do
    $redis.keys.each do |key|
      $redis.del key
    end
  end

  it 'should require a unique uid' do
    should validate_presence_of(:uid)
    should validate_uniqueness_of(:uid)
  end


  describe 'user.token' do
    it 'should require a client_id, display_name, mail, and scope' do
      expect(subject).to respond_to 'token'
      expect{
        subject.token()
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid)
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid,
                      mail: mail)
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid,
                      mail: mail,
                      display_name: display_name)
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid,
                      mail: mail,
                      display_name: display_name,
                      scope: scope)
      }.not_to raise_error
    end

    it 'should create a token, set the value to user credentials with an expire of 4 hours, and return token' do
      token = subject.token(
            client_id: consumer.uuid,
            mail: mail,
            display_name: display_name,
            scope: scope)
      expect(token).to be
      stored_user_info_json = $redis.get(token)
      expect(stored_user_info_json).to be
      stored_user_info = JSON.parse(stored_user_info_json)
      expected_ttl = $redis.ttl(token)
      expect(expected_ttl).not_to eq(-1)
      expect(expected_ttl).to be > min_secs
      expect(expected_ttl).to be <= full_expire
      expect(stored_user_info.symbolize_keys!).to eq(expected_credentials)
    end
  end

  describe 'User.credentials(token)' do
    let(:token) {
      subject.token(
        client_id: consumer.uuid,
        mail: mail,
        display_name: display_name,
        scope: scope
      )
    }

    it 'should require a token' do
      expect(User).to respond_to 'credentials'
      expect{
        User.credentials()
      }.to raise_error(ArgumentError)
      expect{
        User.credentials(token)
      }.not_to raise_error
    end

    it 'should return the credentials stored for the user if the token exists' do
      expect($redis.exists(token)).to be
      credentials = User.credentials(token)
      cached_info_json = $redis.get(token)
      expected_ttl = $redis.ttl(token)
      expect(expected_ttl).not_to eq(-1)
      expect(expected_ttl).to be > min_secs
      expect(expected_ttl).to be <= full_expire
      credentials = JSON.parse(cached_info_json)
      expect(credentials.symbolize_keys!).to eq(expected_credentials)
    end

    it 'should return nil if the token does not exist' do
      $redis.del(token)
      expect($redis.exists(token)).not_to be
      expect(User.credentials(token)).to be_nil
    end
  end
end
