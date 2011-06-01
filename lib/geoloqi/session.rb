module Geoloqi
  class Session
    attr_reader :auth
    attr_accessor :config

    def initialize(opts={})
      opts[:config] = Geoloqi::Config.new opts[:config] if opts[:config].is_a? Hash
      @config = opts[:config] || (Geoloqi.config || Geoloqi::Config.new)
      self.auth = opts[:auth] || {}
      self.auth[:access_token] = opts[:access_token] if opts[:access_token]
      @connection = Faraday.new(:url => API_URL) do |builder|
        builder.response :logger if @config.enable_logging
        builder.adapter  @config.adapter || :net_http
      end
    end

    def auth=(hash)
      @auth = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end

    def access_token
      @auth[:access_token]
    end

    def access_token?
      !access_token.nil?
    end

    def authorize_url(redirect_uri)
      Geoloqi.authorize_url @config.client_id, redirect_uri
    end

    def get(path)
      run :get, path
    end

    def post(path, body=nil)
      run :post, path, body
    end

    def run(meth, path, body=nil)
      body = body.to_json if body.is_a? Hash

      response = @connection.send(meth) do |req|
        req.url "/#{VERSION.to_s}/#{path.gsub(/^\//, '')}"
        req.headers = headers
        req.body = body if body
      end

      json = JSON.parse response.body
      raise Error.new(json['error'], json['error_description']) if json.is_a?(Hash) && json['error']
      json
    end

    def get_auth(code, redirect_uri)
      require 'client_id and client_secret are required to get access token' unless @config.client_id? && @config.client_secret?
      args = {:client_id => @config.client_id,
              :client_secret => @config.client_secret,
              :code => code,
              :grant_type => 'authorization_code',
              :redirect_uri => redirect_uri}

      response = @connection.post do |req|
        req.url "/#{VERSION.to_s}/oauth/token"
        req.headers['Content-Type'] = 'application/json'
        req.body = args.to_json
      end
      self.auth = JSON.parse response.body
    end

    def headers
      {'Authorization' => "OAuth #{access_token}", 'Content-Type' => 'application/json'}
    end
  end
end