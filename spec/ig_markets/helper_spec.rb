describe IGMarkets::Helper do
  it 'formats dates' do
    expect(IGMarkets::Helper.format_date(Date.new(1950, 1, 2))).to eq('02-01-1950')
  end

  it 'formats date times' do
    expect(IGMarkets::Helper.format_date_time(DateTime.new(1950, 1, 2, 3, 4, 5))).to eq('1950:01:02-03:04:05')
  end
end
