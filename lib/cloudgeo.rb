require 'version'

class Cloudgeo

  def self.config
    @config ||= Hashie::Mash.new(default_config)
    if block_given?
      yield @config
    end
    @config
  end

  def self.default_config
    {
      app_name: 'CloudGeo',
      providers: [:geocodio, :mapbox, :google],
      mapbox: {
        api_key: 'abc123'
      },
      mapquest: {
        api_key: 'abc123'
      },
      geocodio: {
        api_key: 'abc123'
      },
      google: {
        api_key: 'abc123'
      },
      log_file: "cloud_geo.log",
      cache: {}
    }
  end

  def self.geocode(address, options = {})
    # Don't even attempt a geocode for blank address
    return nil if address.empty?

    key = options[:session_id] || SecureRandom.uuid
    logs = []
    providers = options[:providers] || config[:providers]

    providers.each_with_index do |provider, i|
      log = EventLog.new(provider, config, key, options)
      log.original_address = address
      log.attempt = i + 1
      provider_class = provider.to_s.split('_').collect!{ |w| w.capitalize }.join
      if data = Object.const_get("Cloudgeo::#{provider_class}").geocode(address, options)
        log.data = data
        logs << log
        self.write_event_log(log) if data.any?

        # Return all the results for an autocomplete request
        if data.kind_of?(Array)
          return data
        end

        if self.accuracy_check(data, address) || self.canadian_geocode_accuracy_check(data)
          return data
        end
      else
        logs << log
        self.write_event_log(log)
      end
    end

    # No clear winner, so see if the best quality is good enough (> 0.8)
    log = logs.sort_by { |log| log.quality }.last
    if log && (log.quality >= 0.7) || (log.quality > 0.5 && log.data.to_s.downcase.include?(' canada'))
      # Data quality is great right away (>= 0.9 in US or > 0.5 in Canada)
      return log.data
    end

    return nil
  end

  def self.geocode_within_north_america?(lat, lon)
    lat.to_f.between?(5.4995, 83.1621) && lon.to_f.between?(-167.2764, -52.2330)
  rescue
    false
    return nil
  end

  def self.bounding_box(state_names=[])
    bb = BoundingBox.new(state_names)
    bb.calculate
  end

private

  def self.write_event_log(log)
    @logger = Logger.new(config[:log_file])
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
    object = log.object
    @logger.info(object.to_json)
  end

  def self.accuracy_check(data, address)
    case data[:source]
    when :google
      true
    when :geocodio
      data[:quality] >= 0.6 &&
      address.include?(data.dig(:address_components, :postal_code)) &&
      address.downcase.include?(data.dig(:address_components, :street).downcase)
    when :mapbox
      data[:quality] >= 0.6
    else
      data[:quality] >= 0.6 &&
      address.include?(data.dig(:address_components, :postal_code))
    end
  end

  def self.canadian_geocode_accuracy_check(data)
    quality_check = data[:quality] > 0.6
    address_check = data[:address].to_s.downcase.include?(' canada')

    quality_check && address_check
  end
end

require 'hashie'
require 'yaml'
require 'lumberjack'
require 'hash'
require 'geocoder'
require 'event_log'
require 'bounding_box'
require 'httparty'
require 'securerandom'
require 'geocoders/mapbox'
require 'geocoders/mapbox_autocomplete'
require 'geocoders/google_autocomplete'
require 'geocoders/google'
require 'geocoders/mapquest'
require 'geocoders/geocodio'
require 'geocoders/test'
