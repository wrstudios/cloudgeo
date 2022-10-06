require 'spec_helper'
require 'geocoder/results/geocodio'
require_relative 'shared_examples'

RSpec.describe Cloudgeo::Geocodio do
  let(:geocoder) { Cloudgeo::Geocodio }

  before do
    Cloudgeo.config do |c|
      c.app_name = 'Test'
      c.log_file = nil
      c.cache = {}
    end
  end

  it_behaves_like 'a geocoder', :geocodio
end
