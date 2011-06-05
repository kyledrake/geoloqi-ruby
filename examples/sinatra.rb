# A simple Sinatra example demonstrating OAuth2 implementation with Geoloqi

require 'rubygems'
require 'sinatra'
require 'geoloqi'

GEOLOQI_REDIRECT_URI = 'http://example.com'

enable :sessions

def geoloqi
  Geoloqi.config :client_id => 'YOUR OAUTH CLIENT ID', :client_secret => 'YOUR CLIENT SECRET'
  @geoloqi ||= Geoloqi::Session.new :auth => session[:geoloqi_auth]
end

get '/?' do
  session[:geoloqi_auth] = geoloqi.get_auth(params[:code], GEOLOQI_REDIRECT_URI) if params[:code] && !geoloqi.access_token?
  redirect geoloqi.authorize_url(GEOLOQI_REDIRECT_URI) unless geoloqi.access_token?
  username = geoloqi.get('account/username')['username']
  "You have successfully logged in as #{username}!"
end
