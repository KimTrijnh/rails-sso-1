require Rails.root.join('lib/omniauth/strategies/fusionauth')

Rails.application.config.omniauth = Rails.application.config_for(:omniauth)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :fusionauth,
    Rails.application.config.omniauth['fusionauth_client_id'],
    Rails.application.config.omniauth['fusionauth_client_secret'],
    Rails.application.config.omniauth['fusionauth_domain'],
    callback_path: '/auth/fusionauth/callback',
    authorize_params: {
      scope: 'profile email'
    },
    provider_ignores_state: Rails.env.development?
  )
end