Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shibboleth, {
    :uid_field                 => "uid",
    :name_field                => "displayName",
    :info_fields => {
      :email    => "mail",
      :location => "contactAddress",
      :image    => "photo_url",
      :phone    => "contactPhone"
    },
    :debug => true,
    :request_type => :header
  }
end
