require 'json'
require 'faraday'
require 'logger'
require 'geoloqi/config'
require 'geoloqi/error'
require 'geoloqi/session'

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

  def self.authorize_url(client_id=nil, redirect_uri=nil)
    raise "client_id and redirect_uri required to authorize url. Pass with Geoloqi.config" unless client_id && redirect_uri
    "#{API_URL}/oauth/authorize?response_type=code&client_id=#{Rack::Utils.escape client_id}&redirect_uri=#{Rack::Utils.escape redirect_uri}"
  end
end