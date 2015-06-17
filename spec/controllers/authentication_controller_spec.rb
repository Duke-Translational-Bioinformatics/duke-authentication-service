require 'rails_helper'
require 'securerandom'

RSpec.describe AuthenticationController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:first_time_user) { FactoryGirl.build(:user) }
  let(:consumer) { FactoryGirl.create(:consumer) }
  let(:display_name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:response_type) { 'token' }
  let(:state) { Faker::Lorem.characters(20) }

  def generate_authenticate_session
    session[:client_id] = consumer.uuid
    session[:state] = state
  end

  def handle_shibboleth_expectation(expected_user)
    expect(session[:uid]).to eq(expected_user.uid)
    expect(session[:display_name]).to eq(display_name)
    expect(session[:email]).to eq(email)
  end

  def login_shib_user(user, display_name, email)
    @request.env['omniauth.auth'] = {
      uid: user.uid,
      info: {
        name: display_name,
        mail: email
      }
    }
  end

  def generate_shib_session(user)
    session[:uid] = user.uid
    session[:display_name] = display_name
    session[:email] = email
  end

  def authorized_consumer_expectation
    expect(assigns(:token)).to be
    token = assigns(:token)
    access_token = consumer.signed_token({
      access_token: token
    })
    token_ttl = $redis.ttl(token)
    params = {
      access_token: access_token,
      token_type: 'Bearer',
      state: session[:state],
      expires_in: token_ttl,
      scope: Rails.application.config.default_scope
    }
    expect(response).to redirect_to(consumer.redirect_uri+'#'+params.to_query)
  end

  def unexpected_request_response
    expect(response.status).to eq(401)
    expect(response.body).to eq('invalid_request')
  end

  describe 'authenticate' do
    it 'should respond with 401 and invalid_request if no url parameters are present' do
      get :authenticate
      unexpected_request_response
    end

    it 'should respond with 401 and invalid_request if consumer does not exist for the client_id specified' do
      non_existent_client_id = SecureRandom.uuid
      expect(non_existent_client_id).not_to eq(consumer.uuid)
      expect(Consumer.where(uuid: non_existent_client_id)).not_to exist
      get :authenticate,
        client_id: non_existent_client_id,
        response_type: response_type,
        scope: Rails.application.config.default_scope,
        state: state
      unexpected_request_response
    end

    it 'should respond with 401 and invalid_request if state is not present' do
      get :authenticate,
        client_id: consumer.uuid,
        response_type: response_type,
        scope: Rails.application.config.default_scope
      unexpected_request_response
    end

    it 'should create session and redirect_to shibboleth_login_url if consumer exists and required parameters are present' do
      get :authenticate,
        client_id: consumer.uuid,
        response_type: response_type,
        scope: Rails.application.config.default_scope,
        state: state
      expect(session[:client_id]).to eq(consumer.uuid)
      expect(session[:state]).to eq(state)
      # scope and response_type are there, but currently unused
      expect(response).to redirect_to(shibboleth_login_url)
    end
  end

  describe 'handle_shibboleth' do
   describe 'when user has not already authorized the consumer' do
     it 'should set user session and redirect_to authorize' do
       generate_authenticate_session
       login_shib_user(first_time_user, display_name, email)
       get :handle_shibboleth
       handle_shibboleth_expectation(first_time_user)
       expect(response).to redirect_to(authorize_url)
     end
   end

   describe 'when user has already authorized the consumer' do
     it 'should create access_token and redirect_to consumer.redirect_uri with expected fragment url parameters' do
       generate_authenticate_session
       login_shib_user(user, display_name, email)
       get :handle_shibboleth
       handle_shibboleth_expectation(user)
       authorized_consumer_expectation
     end
   end
  end

  describe 'authorize' do
    it 'should present the user with a form to allow the consumer access to their profile' do
      generate_authenticate_session
      generate_shib_session(first_time_user)
      get :authorize
      expect(assigns(:user)).to be
      expect(assigns(:user).uid).to eq(first_time_user.uid)
      expect(assigns(:user)).not_to be_persisted
    end
  end

  describe 'process_authorization' do
   describe 'when user declines to authorize the consumer to access their profile' do
     it 'should not create the new user, and redirect_to consumer.uri with expected fragment url parameters' do
       generate_authenticate_session
       generate_shib_session(first_time_user)
       expect {
         post :process_authorization, submitted: 'declined'
       }.to_not change{User.count}
       expect(User.where(uid: first_time_user.uid)).not_to exist
       params = {
         error: 'access_denied',
         state: session[:state]
       }
       expect(response).to redirect_to(consumer.redirect_uri+'#'+params.to_query)
     end
   end

   describe 'when user authorizes the consumer to access their profile' do
     it 'should create new user and access_token and redirect_to consumer.redirect_uri with expected fragment url parameters' do
       generate_authenticate_session
       generate_shib_session(first_time_user)
       expect {
         post :process_authorization, submitted: 'allow'
       }.to change{User.count}.by(1)
       expect(User.where(uid: first_time_user.uid)).to exist
       authorized_consumer_expectation
     end
   end
  end
end
