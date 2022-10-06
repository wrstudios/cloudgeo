require 'spec_helper'
require 'geocoder/results/mapquest'
require_relative 'shared_examples'

RSpec.describe Cloudgeo::Mapquest do
  let(:geocoder) { Cloudgeo::Mapquest }

  before do
    Cloudgeo.config do |c|
      c.app_name = 'Test'
      c.log_file = nil
      c.cache = {}
    end
  end

  it_behaves_like 'a geocoder', :mapquest
end
