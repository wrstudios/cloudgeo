class Cloudgeo::Mapquest

  def self.source
    :mapquest
  end

  def self.api_key
    Cloudgeo.config.mapquest.api_key
  end

  def self.geocode(address, options = {} )
    raw_response = options[:raw_response] || nil

    start_time = Time.now

    Geocoder.configure(
      # geocoding service (see below for supported options):
      :lookup => :mapquest,
      # to use an API key:
      :api_key => self.api_key,
      # geocoding service request timeout, in seconds (default 3):
      :timeout => 3,
      # caching:
      :cache => Cloudgeo.config.cache
    )

    if result = Geocoder.search(address).first
      if raw_response
        return result
      else
        return {
          lat: result.latitude,
          lon: result.longitude,
          address: address,
          address_components: {
            street_address: result.street,
            city: result.city,
            state: result.state,
            postal_code: result.postal_code.split('-').first,
            country: result.country,
          },
          source: self.source,
          quality: calc_quality(result.data['geocodeQualityCode']),
          raw_quality: result.data['geocodeQualityCode'],
          time: Time.now - start_time,
          cache_hit: result.cache_hit
        }
      end
    else
      nil
    end
  end

private

  def self.calc_quality(code)
    # https://developer.mapquest.com/documentation/geocoding-api/quality-codes/
    granularity = {
      'P1' => 1.00,
      'L1' => 0.90,
      'I1' => 0.80,
      'B1' => 0.70,
      'B2' => 0.60,
      'B3' => 0.50,
      'Z1' => 0.40,
      'Z2' => 0.40,
      'Z3' => 0.40,
      'Unknown' => 0.10
    }
    confidence = {
      'A' => 0.00,
      'B' => 0.1,
      'C' => 0.2,
      'Unknown' => 1.00
    }
    (granularity[code[0..1]] || granularity['Unknown']) - (confidence[code[2]] || confidence['Unknown'])
  end

end
