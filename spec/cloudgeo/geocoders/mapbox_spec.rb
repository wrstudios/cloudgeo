require 'spec_helper'
require 'geocoder/results/mapbox'
require_relative 'shared_examples'

RSpec.describe Cloudgeo::Mapbox do
  let(:geocoder) { Cloudgeo::Mapbox }

  before do
    Cloudgeo.config do |c|
      c.app_name = 'Test'
      c.log_file = nil
      c.cache = {}
    end
  end

  it_behaves_like 'a geocoder', :mapbox
end
