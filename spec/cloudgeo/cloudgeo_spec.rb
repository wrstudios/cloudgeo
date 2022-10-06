require 'spec_helper'

RSpec.describe Cloudgeo do
  before do
    Cloudgeo.config do |c|
      c.app_name = 'CloudGeo'
      c.log_file = 'cloud_geo_test.log'
      c.cache = {}
    end
  end

  it 'has version number' do
    expect(Cloudgeo::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end

  describe '#config' do
    it { expect(Cloudgeo.config.app_name).to eq('CloudGeo') }
  end

  describe '#geocode' do
    let(:address) { '123 Main St, Huntington Beach, CA 92648' }
    let(:result) { {lat: 0.00, lon: 0.00, quality: 1.0, address_components: { country: "United States" }} }

    it 'returns the first match of acceptable quality' do
      expect(Cloudgeo::Geocodio).to receive(:geocode).and_return(result.merge!({source: Cloudgeo::Geocodio.source}))
      expect(Cloudgeo.geocode(address)).to eq(result)
    end

    it 'rolls over to the next provider if the first match isn\'t good enough' do
      expect(Cloudgeo::Geocodio).to receive(:geocode).and_return(result.merge({source: Cloudgeo::Geocodio.source, quality: 0.40}))
      expect(Cloudgeo::Mapquest).to receive(:geocode).and_return(result.merge!({source: Cloudgeo::Mapquest.source}))

      expect( Cloudgeo.geocode(address) ).to eq(result)
    end

    it 'returns the best match' do
      expect(Cloudgeo::Mapbox).to receive(:geocode).and_return(result.merge({source: Cloudgeo::Mapbox.source, quality: rand(0.70..0.79)})).twice
      expect(Cloudgeo::Mapquest).to receive(:geocode).and_return(result.merge({source: Cloudgeo::Mapquest.source, quality: rand(0.70..0.79)})).twice
      expect(Cloudgeo::Geocodio).to receive(:geocode).and_return(result.merge({source: Cloudgeo::Geocodio.source, quality: rand(0.70..0.79)})).twice

      best = [:Mapbox, :Geocodio, :Mapquest].collect do |provider|
        r = Cloudgeo.const_get(provider).geocode(address)
      end.sort { |x,y| y[:quality] <=> x[:quality] }.first
      # puts best.inspect
      expect(Cloudgeo.geocode(address)).to eq(best)
    end

    it 'returns nil if the best match is not good enough' do
      expect(Cloudgeo::Mapbox).to receive(:geocode).and_return(result.merge({source: Cloudgeo::Mapbox.source, quality: rand(0.50..0.69)}))
      expect(Cloudgeo::Mapquest).to receive(:geocode).and_return(result.merge({source: Cloudgeo::Mapquest.source, quality: rand(0.50..0.69)}))
      expect(Cloudgeo::Geocodio).to receive(:geocode).and_return(result.merge({source: Cloudgeo::Geocodio.source, quality: rand(0.50..0.69)}))

      expect( Cloudgeo.geocode(address) ).to eq(nil)
    end

    it 'logs multiple low quality requests' do
      add2 = '123 Main St, 92627'
      Cloudgeo.geocode(add2)
    end

    it 'logs multiple low quality requests' do
      address = '1010 EASY ST, Ottawa, Ontario'
      Cloudgeo.geocode(address)
    end

    it 'returns nil for empty address' do
      address = ''
      expect( Cloudgeo.geocode(address) ).to eq(nil)
    end

    it 'doesnt make any requets for blank address' do
      address = ''
      expect(Cloudgeo::Mapbox).to_not receive(:geocode)
      expect(Cloudgeo::Geocodio).to_not receive(:geocode)
      expect(Cloudgeo::Mapquest).to_not receive(:geocode)

      Cloudgeo.geocode(address)

      # expect(Cloudgeo::Mapbox).to_not receive(:geocode)

    end

  end
end
