# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Fusionauth < OmniAuth::Strategies::OAuth2

      option :name, 'fusionauth'
      option :ignore_query_string, true

      args %i[
        client_id
        client_secret
        domain
      ]

      # fusion auth user_id
      uid { raw_info['sub'] }

      info do
        {
          name: raw_info['name'] || raw_info['sub'],
          email: raw_info['email'],
          application_id: raw_info['applicationId']
        }
      end

      def client
        options.client_options.site = domain_url
        options.client_options.authorize_url = '/oauth2/authorize'
        options.client_options.token_url = '/oauth2/token'
        options.client_options.userinfo_url = '/oauth2/userinfo'
        super
      end

      def request_phase
        if no_client_id?
          # Do we have a client_id for this Application?
          fail!(:missing_client_id)
        elsif no_client_secret?
          # Do we have a client_secret for this Application?
          fail!(:missing_client_secret)
        elsif no_domain?
          # Do we have a domain for this Application?
          fail!(:missing_domain)
        else
          redirect client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(options.authorize_params))
        end
      end

      def callback_phase
        super
      end

      private

      def raw_info
        return @raw_info if @raw_info
        # Jwt decode from access_token or request from userinfo_url
        if access_token["id_token"]
          claims, header = jwt_validator.decode(access_token["id_token"])
          @raw_info = claims
        else
          userinfo_url = options.client_options.userinfo_url
          @raw_info = access_token.get(userinfo_url).parsed
        end

        @raw_info
      end

      def callback_url
        full_host + callback_path
      end

      # Check if the options include a client_id
      def no_client_id?
        ['', nil].include?(options.client_id)
      end

      # Check if the options include a client_secret
      def no_client_secret?
        ['', nil].include?(options.client_secret)
      end

      # Check if the options include a domain
      def no_domain?
        ['', nil].include?(options.domain)
      end

      # Normalize a domain to a URL.
      def domain_url
        domain_url = URI(options.domain)
        domain_url = URI("https://#{domain_url}") if domain_url.scheme.nil?
        domain_url.to_s
      end
    end
  end
end