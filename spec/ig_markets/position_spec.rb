describe IGMarkets::Position, :dealing_platform do
  let(:position) { dealing_platform_model build(:position, deal_id: '1') }

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

  it 'returns close levels' do
    expect(profitable_position.close_level).to eq(4.0)
    expect(unprofitable_position.close_level).to eq(4.0)
  end

  it 'calculates price deltas' do
    expect(profitable_position.price_delta).to eq(3.0)
    expect(unprofitable_position.price_delta).to eq(-3.0)
    expect(profitable_position.profitable?).to be true
    expect(unprofitable_position.profitable?).to be false
  end

  it 'calculates profit/loss amounts' do
    expect(profitable_position.profit_loss).to eq(6000)
    expect(unprofitable_position.profit_loss).to eq(-6000)
  end

  it 'calculates payout amounts for binaries' do
    market = build :market_overview, instrument_type: :binary
    position = build :position, size: 100, level: 0.8, market: market

    expect(position.profit_loss).to eq(125)
  end

  it 'reloads itself' do
    expect(dealing_platform.positions).to receive(:[]).with('1').twice.and_return(position)

    position_copy = dealing_platform.positions['1'].dup
    position_copy.direction = nil
    position_copy.reload

    expect(position_copy.direction).to eq(:buy)
  end

  it 'updates itself' do
    body = { limitLevel: 2.0, stopLevel: 1.0, trailingStop: false }
    put_result = { deal_reference: 'reference' }

    expect(session).to receive(:put).with('positions/otc/1', body, IGMarkets::API_V2).and_return(put_result)

    expect(position.update(stop_level: 1, limit_level: 2)).to eq('reference')
  end

  it 'closes itself' do
    body = { dealId: '1', direction: 'SELL', orderType: 'MARKET', size: 10.4, timeInForce: 'EXECUTE_AND_ELIMINATE' }
    delete_result = { deal_reference: 'reference' }

    expect(session).to receive(:delete).with('positions/otc', body).and_return(delete_result)

    expect(position.close).to eq('reference')
  end

  it 'validates close attributes' do
    close_position_proc = proc do |options = {}|
      options = { time_in_force: :execute_and_eliminate }.merge(options)
      position.close options
    end

    expect(session).to receive(:delete).exactly(3).times.and_return(deal_reference: 'reference')

    expect { close_position_proc.call }.not_to raise_error
    expect { close_position_proc.call order_type: :quote }
      .to raise_error(ArgumentError, 'set quote_id if and only if order_type is :quote')
    expect { close_position_proc.call order_type: :quote, quote_id: 'a' }
      .to raise_error(ArgumentError, 'set level if and only if order_type is :limit or :quote')
    expect { close_position_proc.call order_type: :quote, level: 1 }
      .to raise_error(ArgumentError, 'set quote_id if and only if order_type is :quote')
    expect { close_position_proc.call order_type: :quote, quote_id: 'a', level: 1 }.not_to raise_error
    expect { close_position_proc.call order_type: :limit }
      .to raise_error(ArgumentError, 'set level if and only if order_type is :limit or :quote')
    expect { close_position_proc.call order_type: :limit, level: 1 }.not_to raise_error
    expect { close_position_proc.call order_type: :limit, time_in_force: nil }
      .to raise_error(ArgumentError, 'time_in_force attribute must be set')
  end
end
