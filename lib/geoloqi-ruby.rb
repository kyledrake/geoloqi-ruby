require 'json'
require 'faraday'
require 'logger'

module Geoloqi
  VERSION = 1
  API_URL = "https://api.geoloqi.com"
  @@adapter = :net_http
  @@enable_logging = false
  
  class Error < StandardError
    def initialize(type, message=nil)
      type += " - #{message}" if message
      super type
    end
  end
  
  def self.adapter(val=nil)
    return @@adapter if val.nil?
    @@adapter = val
  end

  def self.enable_logging(val=nil)
    return @@enable_logging if val.nil?
    raise ArgumentError, 'Geoloqi.enable_logging must be boolean' unless [true, false].include? val
    @@enable_logging = val
  end

  def self.headers(oauth_token)
    {'Authorization' => "OAuth #{oauth_token}", 'Content-Type' => 'application/json'}
  end

  def self.get(oauth_token, url)
    run :get, oauth_token, url
  end  

  def self.post(oauth_token, url, body)
    run :post, oauth_token, url, body
  end

  def self.run(meth, oauth_token, url, body=nil)
    args = {:head => headers(oauth_token)}
    args[:body] = body.to_json if body

    conn = Faraday.new(:url => API_URL) do |builder|
      builder.request  :json
      builder.response :logger if @@enable_logging
      builder.adapter  @@adapter
    end

    response = conn.post do |req|
      req.url "/#{VERSION.to_s}/#{url.gsub(/^\//, '')}"
      req.headers = headers oauth_token
      req.body = body if body
    end

    response_json = JSON.parse response.body
    raise Error.new(response_json['error'], response_json['error_description']) if response_json.is_a?(Hash) && response_json['error']
    response_json
  end

  def self.get_token(auth_code, redirect_uri)
    args = {:body => {:client_id => Geoloqi::CLIENT_ID,
                                        :client_secret => Geoloqi::CLIENT_SECRET,
                                        :code => auth_code,
                                        :grant_type => "authorization_code",
                                        :redirect_uri => redirect_uri}}
    JSON.parse EM::Synchrony.sync(EventMachine::HttpRequest.new(API_URL+"oauth/token").post(args)).response
  end
end
