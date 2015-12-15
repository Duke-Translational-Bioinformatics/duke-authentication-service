require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:first_time_user) { FactoryGirl.build(:user) }
  let(:consumer) { FactoryGirl.create(:consumer) }
  let(:last_name) { Faker::Name.last_name }
  let(:first_name) { Faker::Name.first_name }
  let(:display_name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:response_type) { 'token' }
  let(:state) { Faker::Lorem.characters(20) }
  let(:non_existent_client_id) { SecureRandom.uuid }

  describe '#authenticate' do
    subject { get :authenticate, request_params }
    let(:request_params) { {
        client_id: consumer.uuid,
        response_type: response_type,
        scope: Rails.application.config.default_scope,
        state: state
    } }

    it_behaves_like 'a successful redirect' do
      let(:expected_redirect_url) { shibboleth_login_url(:protocol => 'https://') }
      it { expect(session[:client_id]).to eq(consumer.uuid) }
      it { expect(session[:state]).to eq(state) }
    end

    context 'without parameters' do
      let(:request_params) { {} }
      it_behaves_like 'an unexpected request'
    end

    context 'with non-existent consumer' do
      let(:request_params) { {
        client_id: non_existent_client_id,
        response_type: response_type,
        scope: Rails.application.config.default_scope,
        state: state
      } }
      it { expect(non_existent_client_id).not_to eq(consumer.uuid) }
      it { expect(Consumer.where(uuid: non_existent_client_id)).not_to exist }
      it_behaves_like 'an unexpected request'
    end

    context 'without state parameter' do
      let(:request_params) { {
        client_id: consumer.uuid,
        response_type: response_type,
        scope: Rails.application.config.default_scope
      } }
      it_behaves_like 'an unexpected request'
    end
  end

  describe '#handle_shibboleth' do
    subject { get :handle_shibboleth }
    include_context 'with authenticated session'
    include_context 'with shibboleth env'

    context 'with existing user' do
      let(:user) { FactoryGirl.create(:user) }

      it_behaves_like 'a successful redirect' do
        include_context 'with consumer redirect url'
        it_behaves_like 'a shibboleth handler'
      end
    end

    context 'with first time user' do
      let(:user) { first_time_user }
 
      it_behaves_like 'a successful redirect' do
        let(:expected_redirect_url) { authorize_url(:protocol => 'https://') }
        it_behaves_like 'a shibboleth handler'
      end
    end
  end

  describe '#authorize' do
    subject { get :authorize }
    include_context 'with authenticated session'
    include_context 'with shibboleth session'

    it_behaves_like 'a successful request' do
      it 'populates the user instance variable' do
        expect(assigns(:user)).to be
        expect(assigns(:user).uid).to eq(user.uid)
        expect(assigns(:user)).not_to be_persisted
      end
    end
  end

  describe '#process_authorization' do
    subject { post :process_authorization, request_params }
    let(:request_params) { {commit: 'allow'} }
    let(:user) { first_time_user }
    include_context 'with authenticated session'
    include_context 'with shibboleth session'

    it 'persists changes' do
      expect { subject }.to change{User.count}.by(1)
      expect(User.where(uid: user.uid)).to exist
    end

    it_behaves_like 'a successful redirect' do
      include_context 'with consumer redirect url'
      let(:token_params) { {
        access_token: token,
        token_type: 'Bearer',
        state: session[:state],
        expires_in: token_ttl,
        scope: Rails.application.config.default_scope
      } }
    end

    context 'when user declines' do
      let(:request_params) { {commit: 'deny'} }

      it 'should not persist changes' do
        expect { subject }.to_not change{User.count}
        expect(User.where(uid: user.uid)).not_to exist
      end

      it_behaves_like 'a successful redirect' do
        include_context 'with consumer redirect url'
        let(:token_params) { {
          error: 'access_denied',
          state: session[:state]
        } }
      end
    end
  end
end
