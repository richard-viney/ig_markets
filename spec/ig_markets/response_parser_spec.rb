describe IGMarkets::ResponseParser do
  it 'snake cases camel case keys' do
    parsed = IGMarkets::ResponseParser.parse(update: 1, updateTime: 1, updateTimeUTC: 1, updateUTCTime: 1)

    expect(parsed).to eq(update: 1, update_time: 1, update_time_utc: 1, update_utc_time: 1)
  end

  it 'parses arrays' do
    parsed = IGMarkets::ResponseParser.parse([{ aB: 1 }, { cD: 2 }])

    expect(parsed).to eq([{ a_b: 1 }, { c_d: 2 }])
  end
end
