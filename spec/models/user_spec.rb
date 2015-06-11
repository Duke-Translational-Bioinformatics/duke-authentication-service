require 'rails_helper'

RSpec.describe User do
  let(:uid) {$uid = "#{Faker::Name.name}#{Faker::Number.number(3)}"}
  let(:display_name) {$display_name = Faker::Name.name}
  let(:mail) {$mail = Faker::Internet.email}
  let(:user) {User.new(uid: uid, display_name: display_name, mail: mail)}

  after(:all) do
    $redis.keys.each do |key|
      $redis.del key
    end
  end

  it 'should require uid, display_name, mail in constructor' do
    expect{
      User.new(display_name: display_name, mail: mail)
    }.to raise_error(ArgumentError)
    expect{
      User.new(uid: uid, mail: mail)
    }.to raise_error(ArgumentError)
    expect{
      User.new(display_name: display_name, uid: uid)
    }.to raise_error(ArgumentError)
    expect{
      User.new(uid: uid, display_name: display_name, mail: mail)
    }.to_not raise_error
  end

  it 'should have a uid' do
    expect(user).to respond_to 'uid'
    expect(user.uid).to eq(uid)
  end

  it 'should have a display_name' do
    expect(user).to respond_to 'display_name'
    expect(user.display_name).to eq(display_name)
  end

  it 'should have a mail' do
    expect(user).to respond_to 'mail'
    expect(user.mail).to eq(mail)
  end

  describe 'user.auth_code' do
    let(:min_secs) { $min_secs = 3 * 60 * 60 }
    let(:full_expire) { $full_expire = 4 * 60 * 60 }

    it 'should create a new auth_code, set auth_code value to user credentials with an expire of 4 hours, and return auth_code' do
      expect(user).to respond_to 'auth_code'
      auth_code = user.auth_code
      expect(auth_code).to be
      stored_user_info_json = $redis.get(auth_code)
      expect(stored_user_info_json).to be
      stored_user_info = JSON.parse(stored_user_info_json)
      expect(stored_user_info).to have_key(:credentials)
      expect(stored_user_info[:credentials]).to eq(user.to_json)
      expected_ttl = $redist.ttl(auth_code)
      expect(expected_ttl).not_to eq(-1)
      expect(expected_ttl).to be > min_secs
      expect(expected_ttl).to be < full_expire
    end
  end

  describe 'User.token(auth_code)' do
    let(:auth_code) {$auth_code = user.auth_code}
    it 'should require an auth_code' do
      expect(User).to respond_to 'token'
      expect{
        User.token()
      }.to raise_error(ArgumentError)
    end

    it 'should return new token for user if auth_code exists' do
      expect($redis.exists(auth_code)).to be
      token = User.token(auth_code)
      expect(token).to be
      cached_info_json = $redis.get(auth_code)
      expected_ttl = $redis.ttl(auth_code)
      expect(expected_ttl).not_to eq(-1)
      expect(expected_ttl).to be > min_secs
      expect(expected_ttl).to be < full_expire
      cached_info = JSON.parse(cached_info_json)
      expect(cached_info).to have_key(:token)
      expect(cached_info[:token]).to eq(token)
      expect(cached_info).to have_key(:credentials)
      expect(cached_info[:credentials]).to eq(user.to_json)
    end

    it 'should return nil if the auth_code does not exist' do
      $redis.del(auth_code)
      expect($redis.exists(auth_code)).not_to be
      expect(User.token(auth_code)).to be_nil
    end
  end

  describe 'User.credentials(auth_code, token)' do
    let(:auth_code) {$auth_code = user.auth_code}
    let(:token) {$token = User.token(auth_code)}

    it 'should require an auth_code and token' do
      expect(User).to respond_to 'credentials'
      expect{
        User.credentials()
      }.to raise_error(ArgumentError)
      expect{
        User.credentials(auth_code)
      }.to raise_error(ArgumentError)
    end

    it 'should return the credentials stored for the user if the auth_code exists and the token matches' do
      expect($redis.exists(auth_code)).to be
      credentials = User.credentials(auth_code, token)
      cached_info_json = $redis.get(auth_code)
      expected_ttl = $redis.ttl(auth_code)
      expect(expected_ttl).not_to eq(-1)
      expect(expected_ttl).to be > min_secs
      expect(expected_ttl).to be < full_expire
      cached_info = JSON.parse(cached_info_json)
      expect(credentials).to eq(user.to_json)
    end

    it 'should return nil if the auth_code does not exist' do
      $redis.del(auth_code)
      expect($redis.exists(auth_code)).not_to be
      expect(User.credentials(auth_code, token)).to be_nil
    end

    it 'should raise a DukeAuthenticationService::TokenException if the token does not match' do
      expect($redis.exists(auth_code)).to be
      expect {
        credentials = User.credentials(auth_code,'notatoken')
      }.to raise_exception(DukeAuthenticationService::TokenException)
    end
  end
end
