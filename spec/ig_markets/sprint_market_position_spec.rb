describe IGMarkets::SprintMarketPosition do
  it 'correctly formats position size' do
    expect(build(:sprint_market_position, direction: :buy, size: 2).formatted_size).to eq('+2')
    expect(build(:sprint_market_position, direction: :sell, size: 3).formatted_size).to eq('-3')
  end
end
