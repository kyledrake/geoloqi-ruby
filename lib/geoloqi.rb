require 'json'
require 'faraday'
require 'logger'

module Geoloqi
  VERSION = 1
  API_URL = 'https://api.geoloqi.com'
  @@adapter = :net_http
  @@enable_logging = false
  @@config = nil

  def self.config(opts=nil)
    return @@config if opts.nil?
    @@config = Config.new opts
  end

  class Config
    attr_accessor :client_id, :client_secret, :adapter, :enable_logging
    def initialize(opts={})
      opts.each {|k,v| send("#{k}=", v)}
      self.enable_logging ||= false
      raise ArgumentError, 'enable_logging must be boolean' unless [true, false].include? self.enable_logging
    end
  end

  class Error < StandardError
    def initialize(type, message=nil)
      type += " - #{message}" if message
      super type
    end
  end

  def self.authorize_url(client_id=nil, redirect_uri=nil)
    raise "client_id and redirect_uri required to authorize url. Pass with Geoloqi.config" unless client_id && redirect_uri
    "#{API_URL}/oauth/authorize?response_type=code&client_id=#{Rack::Utils.escape client_id}&redirect_uri=#{Rack::Utils.escape redirect_uri}"
  end

  class Session
    attr_accessor :oauth_token, :config
    def initialize(opts={})
      opts[:config] = Geoloqi::Config.new opts[:config] if opts[:config].is_a? Hash
      @config = opts[:config] || (Geoloqi.config || Geoloqi::Config.new)
      raise ArgumentError, 'Please supply a config for Geoloqi, either directly or via Geoloqi.config' unless @config.is_a?(Config)
      @oauth_token = opts[:oauth_token]
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
      args[:body] = body.to_json if body

      conn = Faraday.new(:url => API_URL) do |builder|
        builder.request  :json
        builder.response :logger if @config.enable_logging
        builder.adapter  @config.adapter || :net_http
      end

      response = conn.post do |req|
        req.url "/#{VERSION.to_s}/#{path.gsub(/^\//, '')}"
        req.headers = headers
        req.body = body if body
      end

      json = JSON.parse response.body
      raise Error.new(json['error'], json['error_description']) if json.is_a?(Hash) && json['error']
      json
    end

    def headers
      {'Authorization' => "OAuth #{@oauth_token}", 'Content-Type' => 'application/json'}
    end

    def get_access_token(auth_code, redirect_uri)
      args = {:body => {:client_id => Geoloqi::CLIENT_ID,
                        :client_secret => Geoloqi::CLIENT_SECRET,
                        :code => auth_code,
                        :grant_type => "authorization_code",
                        :redirect_uri => redirect_uri}}

      conn = Faraday.new(:url => API_URL) do |builder|
        builder.request  :json
        builder.response :logger if @config.enable_logging
        builder.adapter  @@adapter
      end

      response = conn.post do |req|
        req.url "/#{VERSION.to_s}/#{url.gsub(/^\//, '')}"
        req.headers = headers oauth_token
        req.body = body if body
      end

      JSON.parse EM::Synchrony.sync(EventMachine::HttpRequest.new(API_URL+"oauth/token").post(args)).response
    end
  end
end
