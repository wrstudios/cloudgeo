class Cloudgeo::GooglePlacesDetail

  def self.source
    :google
  end

  def self.api_key
    Cloudgeo.config.google.api_key
  end

  def self.geocode(address, raw_response = false)
    # return {lat: 0.00, lon: 0.00, source: self.source, quality: 1.0}

    start_time = Time.now

    ::Geocoder.configure(
      :lookup => :google_places_details,
      :api_key => self.api_key,
      :timeout => 3,
      :cache => Cloudgeo.config.cache,
    )

    if result = ::Geocoder.search(address).first
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
