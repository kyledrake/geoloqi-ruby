Gem::Specification.new do |s|
  s.name = 'geoloqi'
  s.version = '0.0.1'
  s.authors = ['Kyle Drake', 'Aaron Parecki']
  s.email = ['kyledrake@gmail.com', 'aaron@parecki.com']
  s.homepage = 'https://github.com/kyledrake/geoloqi-ruby'
  s.summary = 'Powerful, flexible, lightweight interface to the awesome Geoloqi platform API'
  s.description = 'Powerful, flexible, lightweight interface to the awesome Geoloqi platform API! Uses Faraday, '+
                  'and can be used with Ruby 1.9 and EM-Synchrony for really fast, highly concurrent development.'

  s.files = `git ls-files`.split("\n")
  s.require_paths = %w[lib]
  s.rubyforge_project = s.name
  s.required_rubygems_version = '>= 1.3.4'

  s.add_dependency 'json'
  s.add_dependency 'faraday'

  s.add_development_dependency 'wrong', '= 0.5.0'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'em-http-request'
  s.add_development_dependency 'em-synchrony'
end
