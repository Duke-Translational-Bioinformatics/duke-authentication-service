require 'rails_helper'
require 'jwt'

describe DukeAuth::V1::UserAPI do
  def missing_token_expectations
    expect(response.status).to eq(401)
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq(401)
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq('consumer not recognized')
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq('only recognized consumers can use this service')
  end

  def invalid_token_expectations
    expect(response.status).to eq(401)
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq(401)
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq('consumer not recognized')
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq('only recognized consumers can use this service')
  end

  def wrong_id_expectations
    expect(response.status).to eq(403)
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq(403)
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq('forbidden')
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq('you do not have the ability to perform this operation')
  end

  let(:json_headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json'} }
  let(:consumer) {$consumer = FactoryGirl.create(:consumer)}

  describe 'get profile' do
    it 'should return user profile with a registered consumer jwt once after successful login' do
      get "/api/v1/profile/#{user.id}", nil, {'Authorization' => user_token}.merge(json_headers)
      expect(response.status).to eq(200)
    end

    it 'should not return their profile more than once after a single login' do
      get "/api/v1/profile/#{user.id}", nil, {'Authorization' => user_token}.merge(json_headers)
      expect(response.status).to eq(404)
      response_json = JSON.parse(response.body)
      expect(response_json).to have_key('error')
      expect(response_json['error']).to eq(404)
      expect(response_json).to have_key('reason')
      expect(response_json['reason']).to eq('user not found')
      expect(response_json).to have_key('suggestion')
      expect(response_json['suggestion']).to eq('this user does not exist, or has not logged in')
    end

    it 'should return an appropriate error if the jwt is not present' do
      get "/api/v1/user/#{user.id}", json_headers
      missing_token_expectations
    end

    it 'should return an appropriate error if the jwt is invalid' do
      get "/api/v1/user/#{user.id}", nil, {'Authorization': 'invalidToken'}.merge(json_headers)
      invalid_token_expectations
    end
    it 'should return an appropriate error if the user is withdrawn' do
      get "/api/v1/user/#{user.id}", nil, {'Authorization': withdrawn_user.auth_token}.merge(json_headers)
      withdrawn_user_token_expectations(withdrawn_user)
    end
  end #get profile
end
