describe IGMarkets::Instrument do
  it 'adjusts API attributes correctly' do
    expect(IGMarkets::Instrument::OpeningHours.adjusted_api_attributes({})).to eq({})
    expect(IGMarkets::Instrument::OpeningHours.adjusted_api_attributes(market_times: [])).to eq([])
  end
end
