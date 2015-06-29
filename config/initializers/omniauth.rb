Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shibboleth, {
    :uid_field                 => "uid",
    :name_field                => "displayName",
    :info_fields => {
      :mail => 'mail',
      :sn => 'sn',
      :givenname => 'givenname'
    },
#    :debug => true,
    :request_type => :header
  }
end
