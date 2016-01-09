describe IGMarkets::ResponseParser do
  it 'snake cases camel case keys' do
    parsed = IGMarkets::ResponseParser.parse(update: 1, updateTime: 1, updateTimeUTC: 1, updateUTCTime: 1)

    expect(parsed).to eq(update: 1, update_time: 1, update_time_utc: 1, update_utc_time: 1)
  end
end
