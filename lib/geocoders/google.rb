class Cloudgeo::Google

  def self.source
    :google
  end

  def self.api_key
    Cloudgeo.config.google.api_key
  end

  def self.geocode(address, options = {} )
    raw_response = options[:raw_response] || nil

    start_time = Time.now

    ::Geocoder.configure(
      # geocoding service (see below for supported options):
      :lookup => :google,
      # to use an API key:
      :api_key => self.api_key,
      # geocoding service request timeout, in seconds (default 3):
      :timeout => 3,
      # caching:
      :cache => Cloudgeo.config.cache,
    )

    if result = ::Geocoder.search(address).first
      if raw_response
        return result
      else
        return {
          lat: result.latitude,
          lon: result.longitude,
          address: result.address,
          address_components: {
            number: result.street_number,
						street_address: result.street_address,
            city: result.city,
            state: result.state,
            postal_code: result.postal_code,
            country: result.country,
          },
          source: self.source,
          quality: calc_quality(result.precision),
          raw_quality: result.precision,
          time: Time.now - start_time,
          cache_hit: result.cache_hit,
        }
      end
    else
      nil
    end
	end

private

	def self.calc_quality(precision)
		case precision
		when "ROOFTOP", "RANGE_INTERPOLATED", "GEOMETRIC_CENTER"
			1.00
		else
			0.80
		end
	end
end

