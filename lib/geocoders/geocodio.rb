class Cloudgeo::Geocodio

  def self.source
    :geocodio
  end

  def self.api_key
    Cloudgeo.config.geocodio.api_key
  end

  def self.geocode(address, options = {} )
    raw_response = options[:raw_response] || nil

    start_time = Time.now

    ::Geocoder.configure(
      # geocoding service (see below for supported options):
      :lookup => :geocodio,
      # to use an API key:
      :api_key => self.api_key,
      # geocoding service request timeout, in seconds (default 3):
      :timeout => 3,
      # caching:
      :cache => Cloudgeo.config.cache
    )

    if result = ::Geocoder.search(address).first
      if raw_response
        return result
      else
        return {
          lat: result.latitude,
          lon: result.longitude,
          address: result.address || address,
          address_components: {
            number: result.number,
            street: result.data['address_components']['formatted_street'],
            street_address: result.street_address,
            city: result.city,
            state: result.state,
            postal_code: result.postal_code,
            country: result.country,
          },
          source: self.source,
          quality: calc_quality(result.data['accuracy'], result.data['accuracy_type']),
          raw_quality: [result.data['accuracy'], result.data['accuracy_type']].join(', '),
          time: Time.now - start_time,
          cache_hit: result.cache_hit
        }
      end
    else
      nil
    end
  end

private

  def self.calc_quality(accuracy, accuracy_type)
    # https://geocod.io/docs/#accuracy-score
    # We're going to reduce the accuracy score by
    # these amounts based on the accuracy type
    accuracy_type_reduction = {
      rooftop: 0,
      point: 0,
      range_interpolation: 0.1,
      street_center: 0.2,
      place: 0.5,
      state: accuracy
    }

    # Don't let it be less than zero
    begin
      [accuracy - accuracy_type_reduction[accuracy_type.to_sym], 0].max
    rescue
      0
    end
  end

end
