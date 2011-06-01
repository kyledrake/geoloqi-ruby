raise ArgumentError, 'usage: be ruby spec/geoloqi_spec.rb "client_id" "client_secret" "access_token"' unless ARGV.length == 3
Bundler.setup
require 'geoloqi'
require 'minitest/autorun'
require 'wrong'
require 'wrong/adapters/minitest'

Wrong.config.alias_assert :expect

describe Geoloqi do
  it 'reads geoloqi config' do
    Geoloqi.config :client_id => 'client_id', :client_secret => 'client_secret'
    expect { Geoloqi.config.is_a?(Geoloqi::Config) }
  end

  it 'returns authorize url' do
    authorize_url = Geoloqi.authorize_url 'test', 'http://blah.blah/test'
    expect { authorize_url == "#{Geoloqi::OAUTH_URL}?"+
                              'response_type=code&'+
                              "client_id=#{Rack::Utils.escape 'test'}&"+
                              "redirect_uri=#{Rack::Utils.escape 'http://blah.blah/test'}" }
  end
end

describe Geoloqi::Config do
  it 'throws exception if non-boolean value is fed to logging' do
    expect { rescuing { Geoloqi.config(:client_id => '', :client_secret => '', :enable_logging => :cats )}.class == ArgumentError }
  end

  it 'correctly checks booleans for client_id and client_secret' do
    [:client_id, :client_secret].each do |k|
      expect { Geoloqi.config(k => '').send("#{k}?") == false }
      expect { Geoloqi.config(k => nil).send("#{k}?") == false }
      expect { Geoloqi.config(k => 'lol').send("#{k}?") == true }
    end
  end
end

describe Geoloqi::Session do

  describe 'with nothing passed' do
    before do
      @session = Geoloqi::Session.new
    end

    it 'should not find access token' do
      expect { !@session.access_token? }
    end
  end

  describe 'with access token and no config' do
    before do
      @session = Geoloqi::Session.new :access_token => ARGV[2]
    end

    it 'successfully makes call to api with forward slash' do
      response = @session.get '/layer/info/Gx'
      expect { response['layer_id'] == 'Gx' }
    end

    it 'successfully makes call to api without forward slash' do
      response = @session.get '/layer/info/Gx'
      expect { response['layer_id'] == 'Gx' }
    end

    it 'creates a layer, reads its info, and then deletes the layer' do
      layer_id = @session.post('/layer/create', :name => 'Test Layer')['layer_id']
      layer_info = @session.get "/layer/info/#{layer_id}"
      layer_delete = @session.post "/layer/delete/#{layer_id}"

      expect { layer_id.is_a?(String) }
      expect { !layer_id.empty? }
      expect { layer_info['name'] == 'Test Layer' }
      expect { layer_delete['result'] == 'ok' }
    end
  end

  describe 'with oauth id, secret, and access token via Geoloqi::Config' do
    it 'should load config' do
      @session = Geoloqi::Session.new :access_token => ARGV[2], :config => Geoloqi::Config.new(:client_id => ARGV[0],
                                                                                               :client_secret => ARGV[1])
      expect { @session.config.client_id == ARGV[0] }
      expect { @session.config.client_secret == ARGV[1] }
    end
  end

  describe 'with em synchrony adapter and access token' do
    it 'makes call to api' do
      session = Geoloqi::Session.new :access_token => ARGV[2], :config => {:adapter => :em_synchrony}
      response = session.get 'layer/info/Gx'
      expect { response['layer_id'] == 'Gx' }
    end
  end

  describe 'with client id, client secret, and access token via direct hash' do
    before do
      @session = Geoloqi::Session.new :access_token => ARGV[2], :config => {:client_id => ARGV[0], :client_secret => ARGV[1]}
    end

    it 'should return access token' do
      expect { @session.access_token == ARGV[2] }
    end

    it 'should recognize access token exists' do
      expect { @session.access_token? }
    end

    it 'gets authorize url' do
      authorize_url = @session.authorize_url('http://blah.blah/test')
      expect { authorize_url == "#{Geoloqi::OAUTH_URL}?"+
                                "response_type=code&"+
                                "client_id=#{Rack::Utils.escape ARGV[0]}&"+
                                "redirect_uri=#{Rack::Utils.escape 'http://blah.blah/test'}" }
    end
  end
end
