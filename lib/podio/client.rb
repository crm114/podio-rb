require 'podio/middleware/logger'
require 'podio/middleware/oauth2'
require 'podio/middleware/podio_api'
require 'podio/middleware/yajl_response'
require 'podio/middleware/error_response'

module Podio
  class Client
    attr_reader :api_url, :api_key, :api_secret, :debug, :oauth_token, :connection

    def initialize(options = {})
      @api_url = options[:api_url] || Podio.api_url || 'https://api.podio.com'
      @api_key = options[:api_key] || Podio.api_key
      @api_secret = options[:api_secret] || Podio.api_secret
      @debug = options[:debug] || Podio.debug
      @oauth_token = options[:oauth_token]

      @connection = configure_connection
      @oauth_connection = configure_oauth_connection
    end

    def get_access_token(username, password)
      response = connection.post do |req|
        req.url '/oauth/token', :grant_type => 'password', :client_id => api_key, :client_secret => api_secret, :username => username, :password => password
      end

      @oauth_token = OAuthToken.new(response.body)
      configure_oauth
      @oauth_token
    end

    def refresh_access_token
      response = @oauth_connection.post do |req|
        req.url '/oauth/token', :grant_type => 'refresh_token', :refresh_token => oauth_token.refresh_token, :client_id => api_key, :client_secret => api_secret
      end

      @oauth_token.access_token = response.body['access_token']
    end

  private

    def configure_connection
      params = {}
      params[:oauth_token] = oauth_token.access_token if oauth_token

      Faraday::Connection.new(:url => api_url, :params => params, :headers => default_headers, :request => {:client => self}) do |builder|
        builder.use Faraday::Request::Yajl
        builder.use Middleware::PodioApi
        builder.use Middleware::OAuth2
        builder.use Middleware::Logger
        builder.adapter Faraday.default_adapter
        builder.use Middleware::YajlResponse
        builder.use Middleware::ErrorResponse
      end
    end

    def configure_oauth_connection
      conn = @connection.dup
      conn.options[:client] = self
      conn.params = {}
      conn
    end

    def configure_oauth
      @connection = configure_connection
    end

    def default_headers
      { :user_agent => 'Podio Ruby Library' }
    end
  end
end