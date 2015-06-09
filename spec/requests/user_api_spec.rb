require 'rails_helper'

describe Dihiface::V1::UserAPI do
  def missing_token_expectations
    expect(response.status).to eq(401)
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq(401)
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq('please login')
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq('you must login to access your account')
  end

  def invalid_token_expectations
    expect(response.status).to eq(401)
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq(401)
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq('invalid token')
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq('your token must have been corrupted, please try again')
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
  let(:user) { $user = FacoryGirl.create(:user)}

  describe 'get profile' do
    it 'should return their profile with their jwt' do
      get "/api/v1/profile/#{user.id}", nil, {'Authorization' => user_token}.merge(json_headers)
      expect(response.status).to eq(200)
      expect(response.body).to eq(UserSerializer.new(user, root: false).to_json)
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
