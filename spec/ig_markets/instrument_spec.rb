describe IGMarkets::Instrument do
  it 'accepts DFB as an expiry' do
    expect(build(:instrument, expiry: 'DFB').expiry).to eq(nil)
  end

  it 'adjusts API attributes' do
    expect(IGMarkets::Instrument::OpeningHours.adjusted_api_attributes({})).to eq({})
    expect(IGMarkets::Instrument::OpeningHours.adjusted_api_attributes(market_times: [])).to eq([])
  end
end
