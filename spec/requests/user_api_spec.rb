require 'rails_helper'
require 'jwt'

describe DukeAuth::V1::UserAPI do
  let(:json_headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json'} }
  let(:consumer) {FactoryGirl.create(:consumer)}
  let (:user) { FactoryGirl.create(:user) }
  let(:display_name) { Faker::Name.name }
  let(:mail) { Faker::Internet.email }
  let(:scope) { 'display_name mail uid' }
  let (:token) { 
    user.token(
      client_id: consumer.uuid,
      display_name: display_name, 
      mail: mail, 
      scope: scope
    ) 
  }

  describe 'get token_info' do
    it 'should respond with a JSON object that describes the valid token' do
      get "/api/v1/token_info/", {access_token: 'valid_token'}, json_headers
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body).not_to eq('null')

      response_json = JSON.parse(response.body)
      expect(response_json).to have_key('audience')
      expect(response_json['audience']).to eq('FOO')
      expect(response_json).to have_key('uid')
      expect(response_json['uid']).to eq('FOO')
      expect(response_json).to have_key('scope')
      expect(response_json['scope']).to eq('FOO')
      expect(response_json).to have_key('expires_in')
      expect(response_json['expires_in']).to eq(999)
    end

    it 'should respond with an error for an expired token' do
      get "/api/v1/token_info/", {access_token: 'expired_token'}, json_headers
      expect(response.status).to eq(400)
      expect(response.body).to be
      expect(response.body).to eq('{"error":"invalid_token"}')
    end

    it 'should respond with an error for a tampered token' do
      get "/api/v1/token_info/", {access_token: 'tampered_token'}, json_headers
      expect(response.status).to eq(400)
      expect(response.body).to be
      expect(response.body).to eq('{"error":"invalid_token"}')
    end

    it 'should respond with an error for a revoked token' do
      get "/api/v1/token_info/", {access_token: 'revoked_token'}, json_headers
      expect(response.status).to eq(400)
      expect(response.body).to be
      expect(response.body).to eq('{"error":"invalid_token"}')
    end
  end #get token_info
end
