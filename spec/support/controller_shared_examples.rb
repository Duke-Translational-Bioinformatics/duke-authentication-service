shared_examples 'a successful request' do
  before do
    is_expected.to be_success
  end
end

shared_examples 'an unexpected request' do
  before do
    is_expected.not_to be_success
  end

  it 'responds with 401 and invalid_request' do
    expect(response.status).to eq(401)
    expect(response.body).to eq('invalid_request')
  end
end

shared_examples 'a successful redirect' do
  before do
    is_expected.to be_redirect
  end

  it { expect(response).to redirect_to(expected_redirect_url) }
end

shared_context 'with authenticated session' do
  before do
    session[:client_id] = consumer.uuid
    session[:state] = state
  end
end

shared_context 'with shibboleth env' do
  before do
    @request.env['omniauth.auth'] = {
      uid: user.uid,
      info: {
        givenname: first_name,
        sn: last_name,
        name: display_name,
        mail: email
      }
    }
  end
end

shared_context 'with shibboleth session' do
  before do
    session[:uid] = user.uid
    session[:first_name] = first_name
    session[:last_name] = last_name
    session[:display_name] = display_name
    session[:email] = email
  end
end

shared_examples 'a shibboleth handler' do
  it 'sets session variables' do
    expect(session[:uid]).to eq(user.uid)
    expect(session[:first_name]).to eq(first_name)
    expect(session[:last_name]).to eq(last_name)
    expect(session[:display_name]).to eq(display_name)
    expect(session[:email]).to eq(email)
  end
end

shared_context 'with consumer redirect url' do
  let(:token) { assigns(:token) }
  let(:token_ttl) { $redis.ttl(token) }
  let(:token_params) { {
    access_token: token,
    token_type: 'Bearer',
    state: session[:state],
    expires_in: token_ttl,
    scope: Rails.application.config.default_scope
  } }
  let(:token_fragment) { token_params.to_query }
  let(:expected_redirect_url) { consumer.redirect_uri+'#'+token_fragment }
end
