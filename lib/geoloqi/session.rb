module Geoloqi
  class Session
    attr_accessor :oauth_token, :config
    def initialize(opts={})
      opts[:config] = Geoloqi::Config.new opts[:config] if opts[:config].is_a? Hash
      @config = opts[:config] || (Geoloqi.config || Geoloqi::Config.new)
      @oauth_token = opts[:oauth_token]
      @connection = Faraday.new(:url => API_URL) do |builder|
        builder.response :logger if @config.enable_logging
        builder.adapter  @config.adapter || :net_http
      end
    end

    def authorize_url(redirect_uri)
      Geoloqi.authorize_url @config.client_id, redirect_uri
    end

    def get(path)
      run :get, path
    end

    def post(path, body)
      run :post, path, body
    end

    def run(meth, path, body=nil)
      args = {:head => headers}
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

    def get_oauth_token(auth_code, redirect_uri)
      require 'client_id and client_secret are required to get oauth token' unless @config.client_id? && @config.client_secret?
      args = {:body => {:client_id => @config.client_id,
                        :client_secret => @config.client_secret,
                        :code => auth_code,
                        :grant_type => "authorization_code",
                        :redirect_uri => redirect_uri}}

      response = @connection.post do |req|
        req.url "#{API_URL}/oauth/token"
        req.body = args
      end
      puts response.inspect
    end

    def headers
      {'Authorization' => "OAuth #{@oauth_token}", 'Content-Type' => 'application/json'}
    end
  end
end
