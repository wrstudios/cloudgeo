class Cloudgeo::Mapbox

  def self.source
    :mapbox
  end

  def self.api_key
    Cloudgeo.config.mapbox.api_key
  end

  def self.dataset
    self.use_permanent_dataset ? 'mapbox.places-permanent' : 'mapbox.places'
  end

  def self.use_permanent_dataset
    Cloudgeo.config.mapbox.use_permanent_dataset || false
  end

  def self.geocode(address, options = {} )
    raw_response = options[:raw_response] || nil

    # return {lat: 0.00, lon: 0.00, source: self.source, quality: 1.0}

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
      # Turn this on for Geocoder debugging
      # :logger => Lumberjack::Logger.new(STDOUT, level: :debug),
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
      types: "address,postcode",
      proximity: proximity,
      bbox: bbox
    }

    resp = ::Geocoder.search(address, params: params)
    if result = resp.first
      if raw_response
        return result
      else
        return {
          lat: result.latitude,
          lon: result.longitude,
          address: result.data['place_name'] || address,
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
    else
      nil
    end
  end

end
