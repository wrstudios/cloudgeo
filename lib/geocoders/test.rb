class Cloudgeo::Test

  def self.source
    :test
  end

  def self.api_key
    nil
  end

  def self.geocode(address, raw_response = false)
    # return {lat: 0.00, lon: 0.00, source: self.source, quality: 1.0}

    start_time = Time.now

    ::Geocoder.configure(
      # geocoding service (see below for supported options):
      :lookup => :test
    )

    {
      lat: 40.7143528,
      lon: -74.0059731,
      address: address,
      address_components: {
        number: '280',
        street: 'Brodway',
        street_address: '280 Broadway',
        city: 'New York',
        state: 'NY',
        postal_code: '10007',
        country: 'United States'
      },
      source: self.source,
      quality: 1.0,
      raw_quality: 1.0,
      time: Time.now - start_time,
      cache_hit: false
    }
  end

end
