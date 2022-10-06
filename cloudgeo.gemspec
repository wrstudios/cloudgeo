require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name        = 'cloudgeo'
  s.version     = Cloudgeo::VERSION
  s.date        = '2018-04-23'
  s.summary     = 'Geo-coding across providers for W+R Studios Cloud apps'
  s.description = 'Geo-coding using MapBox, MapQuest, and other providers'
  s.authors     = ['Dan Woolley']
  s.email       = 'dan@wrstudios.com'
  s.files       = ['lib/cloudgeo.rb', 'lib/geocoders/mapbox.rb', 'lib/geocoders/mapquest.rb']
  s.executables << 'cloudgeo'
  s.homepage    = 'http://github.com/wrstudios/cloudgeo'
  s.license     = 'MIT'

  s.add_runtime_dependency 'geocoder', '1.6.7'
  s.add_runtime_dependency 'hashie'
  s.add_runtime_dependency 'lumberjack'
end
