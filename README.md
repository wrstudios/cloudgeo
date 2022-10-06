# Cloud Geo Gem

Configure the gem like this:

```ruby
Cloudgeo.config do |c|
  c.app_name = 'Your App Name'
  c.log_file = STDOUT
  c.cache = {}
  c.providers = [:mapbox, :geocodio, :mapquest. :test]
  c.mapbox.api_key = 'your mapbox key'
  c.geocodio.api_key = 'your mapbox key'
  c.mapquest.api_key = 'your mapquest key'
end
```

The cache attribute works with Hash (temporary cache - only until restart), Redis, and any object that supports these methods:
```
store#[](key) or #get or #read - retrieves a value
store#[]=(key, value) or #set or #write - stores a value
store#del(url) - deletes a value
```
See https://github.com/alexreisner/geocoder for more info.

I suggest using Moneta - https://github.com/minad/moneta - and then configuring the cache like this:
```ruby
c.cache = Moneta.new(:Memory)
or
c.cache = Moneta.new(:Memcached, server: '10.0.2.209:11211')
```

We used this guide to create gem:
http://guides.rubygems.org/make-your-own-gem/

Make sure to build the gem each time you update or rev the version:
```
gem build cloudgeo.gemspec
```

To run the gem using irb:
```
irb -Ilib
```
Then:
```ruby
require 'cloudgeo'
@address = '123 Main St, Huntington Beach, CA 92648'
Cloudgeo.geocode(@address)
Cloudgeo::Mapbox.geocode(@address)
Cloudgeo::Geocodio.geocode(@address)
Cloudgeo::Mapquest.geocode(@address)
```

You can pass 'true' as the second param to each of the individual geocoders to see raw results directly from the provider.

Calls to geocode can take an optional second param of options. One good use if this param is sending metadata to the logs - things like mlscode, mlsnum, etc - for tracking and debugging.
```ruby
Cloudgeo.geocode(@address, {metadata: {mlscode: 'mred', mlsnum: '123456'}})
```
#### Arguments for Cloudgeo instance:
**Cloudgeo.gecode takes two arguments**.
1. Address or Query - This can be a full address OR a query of an address for mapbox autocomplete. `'123 Main St, Huntington Beach, CA 92648'`

2. Second Argument: Options hash
- `providers:` an array of desired providers
  example: ` [:mapbox, :geocodio, :mapquest. :test]`
- `session_id:` the user session id
  example: `'60880520-ac32-11e9-9e1a-67a9c9493b51'` 
- `country:` country code
  example: `'US'` or `'CA'`
- `proximity:` lon and lat of the epicenter as a string
  example: `"-79.3716,43.6319"`
- `metadata:` Meta data to be consumed and sent to log files
  example: `metadata: {mlscode: 'mred', mlsnum: '123456'}`

Implemenataion example using mapbox_autocomplete:
```ruby
query = params[:query]
options = { providers: [:mapbox_autocomplete], 
            session_id: session_id, 
            country: 'US', 
            proximity: "-79.3716, 43.6319",
            metadata: { mlscode: 'mred', mlsnum: '123456'}
          }
result = Cloudgeo.geocode(query, options)
suggestions = result.map {|result| { value: result[:address], coordinates: [result[:lon], result[:lat]] } }
```      


