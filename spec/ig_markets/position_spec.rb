describe IGMarkets::Position do
  let(:profitable_position) do
    market = build :market_overview, bid: 4.0
    build :position, contract_size: 1000, currency: 'USD', level: 1.0, direction: :buy, size: 2, market: market
  end
  let(:unprofitable_position) do
    market = build :market_overview, offer: 4.0
    build :position, contract_size: 1000, currency: 'USD', level: 1.0, direction: :sell, size: 2, market: market
  end

  it 'knows if it has a trailing stop' do
    expect(build(:position).trailing_stop?).to be false
    expect(build(:position, trailing_step: 1, trailing_stop_distance: 10).trailing_stop?).to be true
  end

  it 'returns correct close levels' do
    expect(profitable_position.close_level).to eq(4.0)
    expect(unprofitable_position.close_level).to eq(4.0)
  end

  it 'calculates correct price deltas' do
    expect(profitable_position.price_delta).to eq(3.0)
    expect(unprofitable_position.price_delta).to eq(-3.0)
    expect(profitable_position.profitable?).to be true
    expect(unprofitable_position.profitable?).to be false
  end

  it 'calculates correct profit/loss amounts' do
    expect(profitable_position.profit_loss).to eq(6000)
    expect(unprofitable_position.profit_loss).to eq(-6000)
  end
end
