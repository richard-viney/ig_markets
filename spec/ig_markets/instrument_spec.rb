describe IGMarkets::Instrument do
  it 'accepts different expiry formats' do
    expect(build(:instrument, expiry: '-').expiry).to be_nil
    expect(build(:instrument, expiry: 'DFB').expiry).to be_nil
    expect(build(:instrument, expiry: 'SEP-16').expiry).to eq(Date.new(2016, 9, 1))
    expect(build(:instrument, expiry: '08-DEC-16').expiry).to eq(Date.new(2016, 12, 8))
  end

  it 'adjusts API attributes' do
    expect(IGMarkets::Instrument::OpeningHours.adjusted_api_attributes({})).to eq({})
    expect(IGMarkets::Instrument::OpeningHours.adjusted_api_attributes(market_times: [])).to eq([])
  end
end
