require 'rails_helper'

RSpec.describe User, type: :model do
  let(:display_name) {$display_name = Faker::Name.name}
  let(:mail) {$mail = Faker::Internet.email}
  let(:scope) {$scope = 'email,uid,display_name'}
  let(:min_secs) { $min_secs = 3 * 60 * 60 }
  let(:full_expire) { $full_expire = 4 * 60 * 60 }
  subject { FactoryGirl.create(:user) }

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
    it 'should require a display_name, email, and scope' do
      expect{
        subject.new()
      }.to raise_error(ArgumentError)
      expect{
        subject.new(mail: mail)
      }.to raise_error(ArgumentError)
      expect{
        subject.new(display_name: display_name)
      }.to raise_error(ArgumentError)
      expect{
        subject.new(scope: scope)
      }.to raise_error(ArgumentError)
    end

    it 'should create a token, set the value to user credentials with an expire of 4 hours, and return token' do
      expect(subject).to respond_to 'token'
      token = subject.token(mail: mail, display_name: display_name, scope: scope)
      expect(token).to be
      stored_user_info_json = $redis.get(token)
      expect(stored_user_info_json).to be
      stored_user_info = JSON.parse(stored_user_info_json)
      expected_ttl = $redist.ttl(token)
      expect(expected_ttl).not_to eq(-1)
      expect(expected_ttl).to be > min_secs
      expect(expected_ttl).to be < full_expire
      expect(stored_user_info).to eq({uid: subject.uid, mail: mail, display_name: display_name, scope: scope, expires_in: expected_ttl}.to_json)
    end
  end

  describe 'User.credentials(token)' do
    let(:token) {$token = User.token(mail: mail, display_name: display_name)}

    it 'should require a token' do
      expect(User).to respond_to 'credentials'
      expect{
        User.credentials()
      }.to raise_error(ArgumentError)
    end

    it 'should return the credentials stored for the user if the token exists' do
      expect($redis.exists(token)).to be
      credentials = User.credentials(token)
      cached_info_json = $redis.get(token)
      expected_ttl = $redis.ttl(token)
      expect(expected_ttl).not_to eq(-1)
      expect(expected_ttl).to be > min_secs
      expect(expected_ttl).to be < full_expire
      credentials = JSON.parse(cached_info_json)
      expect(credentials).to eq({uid: subject.uid, mail: mail, display_name: display_name, scope: scope, expires_in: expected_ttl}.to_json)
    end

    it 'should return nil if the token does not exist' do
      $redis.del(token)
      expect($redis.exists(token)).not_to be
      expect(User.credentials(token)).to be_nil
    end
  end
end
