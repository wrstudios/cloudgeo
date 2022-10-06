RSpec.shared_examples 'a geocoder' do |source|
  describe '#source' do
    it { expect(geocoder.source).to eq(source) }
  end

  describe '#geocode' do
    let(:address)  { @fixture['address'] }
    let(:expected) { @fixture['result'] }
    let(:raw_result) do
      klass = Geocoder::Result.const_get(source.capitalize.to_sym)
      klass.new @fixture['raw_result']
    end

    fixtures = YAML.load_file("spec/fixtures/#{source}.yml")
    fixtures.each do |name, fixture|

      it "geocodes #{name}" do
        @fixture = fixture
        expect(Geocoder).to receive(:search).and_return([raw_result])
        actual = geocoder.geocode(address)
        expected.keys.each do |key|
          expect(actual[key.to_sym]).to eq(expected[key])
        end
      end

      it "geocodes #{name} (raw)" do
        @fixture = fixture
        expect(Geocoder).to receive(:search).and_return([raw_result])
        expect(geocoder.geocode(address, {raw_response: true})).to eq(raw_result)
      end

    end
  end
end
