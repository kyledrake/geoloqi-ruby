raise ArgumentError, 'OAuth token is required. Get it from your Geoloqi.com account settings page' unless ARGV[0]

Bundler.setup

require 'geoloqi-ruby'
require 'minitest/autorun'
require 'wrong'
require 'wrong/adapters/minitest'
require 'eventmachine'
require 'em-http-request'
require 'em-synchrony'

Wrong.config.alias_assert :expect

describe Geoloqi do
  it 'throws exception if non-boolean value is fed to logging' do
    expect { rescuing { Geoloqi.enable_logging :cats }.class == ArgumentError }
  end

  it 'successfully makes call to api with forward slash' do
    @response = Geoloqi.get ARGV[0], '/layer/info/Gx'
    expect { @response['layer_id'] == 'Gx' }
  end

  it 'successfully makes call to api with net/http' do
    Geoloqi.adapter :net_http
    @response = Geoloqi.get ARGV[0], 'layer/info/Gx'
    expect { @response['layer_id'] == 'Gx' }
  end

  it 'successfully makes call to api with em-synchrony' do
    EM.synchrony do
      # Geoloqi.enable_logging true
      Geoloqi.adapter :em_synchrony
      @response = Geoloqi.get ARGV[0], 'layer/info/Gx'
      EM.stop
    end
    expect { @response['layer_id'] == 'Gx' }
  end
end
