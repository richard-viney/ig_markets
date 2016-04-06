describe IGMarkets::Position do
  let(:profitable_position) do
    market = build :market_overview, bid: 4.0, lot_size: 3, scaling_factor: 5
    build :position, currency: 'USD', level: 1.0, direction: :buy, size: 2, market: market
  end
  let(:unprofitable_position) do
    market = build :market_overview, offer: 4.0, lot_size: 3, scaling_factor: 5
    build :position, currency: 'USD', level: 1.0, direction: :sell, size: 2, market: market
  end

  it 'knows if it has a trailing stop' do
    expect(build(:position).trailing_stop?).to be false
    expect(build(:position, trailing_step: 1, trailing_stop_distance: 10).trailing_stop?).to be true
  end

  it 'calculates correct price deltas' do
    expect(profitable_position.price_delta).to eq(3.0)
    expect(unprofitable_position.price_delta).to eq(-3.0)
    expect(profitable_position.profitable?).to be true
    expect(unprofitable_position.profitable?).to be false
  end

  it 'calculates correct profit/loss amounts' do
    expect(profitable_position.profit_loss).to eq(90)
    expect(unprofitable_position.profit_loss).to eq(-90)
  end

  it 'correctly formats profit/loss amounts' do
    expect(profitable_position.formatted_profit_loss).to eq('USD 90.00')
    expect(unprofitable_position.formatted_profit_loss).to eq('USD -90.00')
  end

  it 'correctly formats position size' do
    expect(profitable_position.formatted_size).to eq('+2')
    expect(unprofitable_position.formatted_size).to eq('-2')
  end
end
