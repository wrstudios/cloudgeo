class Cloudgeo::MapboxAutocomplete

  def self.source
    :mapbox
  end

  def self.api_key
    Cloudgeo.config.mapbox.api_key
  end

  def self.dataset
    'mapbox.places'
  end

  def self.response_object(result, start_time)
    {
      lat: result.latitude,
      lon: result.longitude,
      address: result.data['place_name'],
      address_components: {
        number: result.data['address'],
        street: result.place_name,
        street_address: [result.data['address'], result.place_name].compact.join(' '),
        city: result.city,
        state: result.state,
        postal_code: result.postal_code,
        country: result.country,
      },
      source: self.source,
      quality: result.data['relevance'].round(3),
      raw_quality: result.data['relevance'].round(3),
      time: Time.now - start_time,
      cache_hit: result.cache_hit,
      dataset: self.dataset
    }
  end

  def self.geocode(address, options = {} )
    raw_response = options[:raw_response] || nil
    start_time = Time.now

    ::Geocoder.configure(
      # geocoding service (see below for supported options):
      :lookup => :mapbox,
      # to use an API key:
      :api_key => self.api_key,
      # geocoding service request timeout, in seconds (default 3):
      :timeout => 3,
      # caching:
      :cache => Cloudgeo.config.cache,
      # Use permanent or ephemeral dataset (default)
      :mapbox => {
        :dataset => self.dataset
      }
    )

    country = options[:country] || 'us'
    proximity = options[:proximity] || nil
    bbox = options[:bbox] || nil

    params = {
      country: country, 
      types: "address",
      proximity: proximity,
      bbox: bbox
    }

    response = ::Geocoder.search(address, params: params)
    results = []

    if response.any?
      response.each do |result|
        results << self.response_object(result, start_time)
      end
    else
      nil
    end

    return results

  end

end
