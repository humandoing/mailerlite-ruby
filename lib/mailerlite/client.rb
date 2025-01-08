# frozen_string_literal: true

require 'http'

MAILERLITE_API_URL = 'https://connect.mailerlite.com/api'

# mailerlite-ruby is a gem that integrates all endpoints from MailerLite API
module MailerLite
  class << self
    attr_accessor :api_token

    # Config method to allow passing API token through an initializer
    def configure
      yield self
    end
  end

  class << self
    attr_accessor :use_dotenv

    def configure
      yield self
    end
  end

  # Inits the client.
  class Client
    def initialize
      if MailerLite.use_dotenv
        require 'dotenv'
        Dotenv.load
        Dotenv.require_keys('MAILERLITE_API_TOKEN')
      end

      # Check for Rails credentials if Rails is defined
      if defined?(Rails) && Rails.application.credentials&.mailer_lite&[:api_token]
        @api_token = Rails.application.credentials.mailer_lite[:api_token]
      else
        # Fall back to ENV variable
        @api_token = ENV.fetch('MAILERLITE_API_TOKEN', nil)
      end
    end

    def headers
      {
        'User-Agent' => "MailerLite-client-ruby/#{MailerLite::VERSION}",
        'Accept' => 'application/json',
        'Content-type' => 'application/json'
      }
    end

    def http
      raise 'API token is missing' unless @api_token

      HTTP
        .timeout(connect: 15, read: 30)
        .auth("Bearer #{@api_token}")
        .headers(headers)
    end
  end
end
