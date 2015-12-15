require 'rails_helper'

RSpec.describe User, type: :model do
  subject { FactoryGirl.create(:user) }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name}
  let(:display_name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:scope) { Rails.application.config.default_scope }
  let(:min_secs) { 3 * 60 * 60 }
  let(:full_expire) { 4 * 60 * 60 }
  let(:consumer) { FactoryGirl.create(:consumer) }
  let(:expected_credentials) { {
      uid: subject.uid,
      client_id: consumer.uuid,
      email: email,
      first_name: first_name,
      last_name: last_name,
      display_name: display_name,
      scope: scope
    }
  }

  it 'should require a unique uid' do
    should validate_presence_of(:uid)
    should validate_uniqueness_of(:uid)
  end


  describe 'user.token' do
    it 'should require a client_id, display_name, email, and scope' do
      expect(subject).to respond_to 'token'
      expect{
        subject.token()
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid)
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid,
                      email: email)
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid,
                      email: email,
                      first_name: first_name)
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid,
                      email: email,
                      first_name: first_name,
                      last_name: last_name)
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid,
                      email: email,
                      first_name: first_name,
                      last_name: last_name,
                      display_name: display_name)
      }.to raise_error(ArgumentError)
      expect{
        subject.token(client_id: consumer.uuid,
                      email: email,
                      first_name: first_name,
                      last_name: last_name,
                      display_name: display_name,
                      scope: scope)
      }.not_to raise_error
    end

    it 'should create a hex string token, set the value to JSON serialized hash of the user credentials with an expire of 4 hours, and return the generated token' do
      token = subject.token(
            client_id: consumer.uuid,
            email: email,
            first_name: first_name,
            last_name: last_name,
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
        email: email,
        first_name: first_name,
        last_name: last_name,
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

    it 'should return a hash with key info equal to the credentials stored for the user, and expires_in equal to the expiration, if the token exists' do
      expect($redis.exists(token)).to be
      credentials = User.credentials(token)
      expected_ttl = $redis.ttl(token)
      expect(credentials).to have_key(:info)
      expect(JSON.parse(credentials[:info]).symbolize_keys!).to eq(expected_credentials)
      expect(credentials).to have_key(:expires_in)
      expect(credentials[:expires_in]).to eq(expected_ttl)
    end

    it 'should return nil if the token does not exist' do
      $redis.del(token)
      expect($redis.exists(token)).not_to be
      expect(User.credentials(token)).to be_nil
    end
  end
end
