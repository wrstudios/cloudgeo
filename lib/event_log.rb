class EventLog
  attr_accessor :data, :object, :config, :key, :score, :original_address, :provider, :attempt, :options

  def initialize(provider, config, key, options={})
    @provider = provider
    @config = config
    @key = key || SecureRandom.uuid
    @options = options

    @start_time = Time.now.utc
    @app_name = config[:app_name] || "CloudGeo"
    @data = {}
  end

  def object
    {
      "@timestamp" => @start_time,
      message: "Cloudgeo Gem - Geocode request to #{provider} by #{config.app_name}",
      ecs: { version: "1.0.0" },
      event: event_object,
      client: client_object,
      original: address,
      source:{
        geo: geo_object
      },
      organization: {
        id: mls_code,
        listing_id: listing_id
      }
    }
    
  end

  def data=(value)
    @data = value.kind_of?(Array) ? value.first : value
  end

  def geo_object
    {
      location: geo_point,
      country_name: country_name,
      address: data[:address]
    }
  end

  def client_object
    if proximity
      lon,lat = proximity.split(',')
      {
        geo: {
          location: {
            lon: lon,
            lat: lat
          }
        }
      }
    else
      nil
    end

    
  end

  def event_object
    {
      id: key,
      severity: attempt,
      application: config.app_name,
      kind: "event",
      outcome: outcome,
      action: "geocode-request",
      module: source,
      duration: Time.now - @start_time,
      created: @start_time,
      risk_score: quality,
      cache_hit: cache_hit,
      api_key: api_key,
      dataset: dataset
    }
  end

  def source
    data[:source] || provider
  end

  def mls_code
    options[:mls_code] || nil
  end

  def listing_id
    options[:listing_id] || nil
  end

  def proximity
    options[:proximity] || nil
  end

  def outcome
    !data.empty? ? "success" : "failure"
  end

  def quality
    data[:quality] || 0 
  end

  def cache_hit
    data[:cache_hit] || false rescue false
  end

  def api_key
    "ending_in-#{config[provider][:api_key][-8..-1]}" rescue ''
  end

  def dataset
    data[:dataset] rescue ''
  end

  def geo_point
    if data[:lon] && data[:lat]
      {
        lon: data[:lon] || nil,
        lat: data[:lat] || nil
      }
    else
      nil
    end
  end

  def country_name
    data[:address_components][:country] rescue nil
  end

  def address
    original_address
  end

end