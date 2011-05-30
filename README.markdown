Geoloqi Library for Ruby
===
Powerful, flexible, lightweight interface to the awesome Geoloqi platform API! Uses Faraday, and can be used with Ruby 1.9 and EM-Synchrony for really fast, highly concurrent development.

This library was developed with two goals in mind: to be as simple as possible, but also to be very powerful to allow for much higher-end development (multiple Geoloqi apps per instance, concurrency, performance).

Installation
---

    gem install geoloqi

Basic Usage
---
Geoloqi uses OAuth2 for authentication, but if you're only working with your own account, you don't need to go through the authorization steps! Simply go to your account settings, click on "Connections" and copy the OAuth 2 Access Token. You can use this token to run the following examples:

	require 'geoloqi'
	geoloqi = Geoloqi::Session.new :oauth_token => 'YOUR OAUTH2 TOKEN GOES HERE'
	response = geoloqi.get 'layer/info/Gx'
	puts response.inspect

This example returns a hash with the following:

	{"layer_id"=>"Gx", "user_id"=>"4", "type"=>"normal", "name"=>"USGS Earthquakes", "description"=>"Real-time notifications of earthquakes near you.", "icon"=>"http://beta.geoloqi.com/images/earthquake-layer.png", "public"=>"1", "url"=>"https://a.geoloqi.com/layer/description/Gx", "subscription"=>false, "settings"=>false}
	
Both GET and POST are supported. To send a POST to create a place (in this case, the entire city of Portland, Oregon):

	response = geoloqi.post 'place/create', {
	  "layer_id" => "1Wn",
	  "name" => "3772756364",
	  "latitude" => "45.5037078163837",
	  "longitude" => "-122.622699737549",
	  "radius" => "3467.44",
	  "extra" => {
	    "description" => "Portland",
	     "url" => "http://en.wikipedia.org/wiki/Portland"
	  }
	}

This returns response['place_id'], which you can use to store and/or remove the place:

	response = geoloqi.post "place/delete/#{response['place_id']}"
	
Which returns response['result'] with a value of "ok".