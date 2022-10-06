class GooglePlaces
  include HTTParty
  # https://maps.googleapis.com/maps/api/place/autocomplete/output?parameters
  base_uri 'https://maps.googleapis.com'

  def initialize(address)
    @options = { 
      query: { 
        input: address, 
        key: Cloudgeo.config.google.api_key,
        types: "address"
      }
    }
  end

  def autocomplete
    self.class.get("/maps/api/place/autocomplete/json", @options)
  end
end

class Cloudgeo::GoogleAutocomplete
  def self.source
    :google_places_autocomplete
  end

  def self.important_keys
    [:description, :place_id].map(&:to_s)
  end

  def self.api_key
    Cloudgeo.config.google.api_key
  end

  def self.dataset
    'places-autocomplete'
  end

  def self.response_object(result, start_time)
    {
      lat: result.latitude,
      lon: result.longitude,
      address: result.data['place_name'],
      address_components: {
        number: result.data['address'],
        street: result.place_name,
        # street_address: [result.data['address'], result.place_name].compact.join(' '),
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

  def self.geocode(address, raw_response = false)
    start_time = Time.now

    places = ::GooglePlaces.new(address)
    predictions = places.autocomplete.parsed_response["predictions"]
    
    if predictions.any?
      places = predictions.inject([]) do |result, element|
        hsh = element.slice(*self.important_keys)
        obj = OpenStruct.new(hsh)
        result << obj
        result
      end
    end

    results = places

    # if response.any?
    #   response.each do |result|
    #     results << self.response_object(result, start_time)
    #   end
    # else
    #   nil
    # end

    return results

  end

end
