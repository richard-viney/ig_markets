describe IGMarkets::Position do
  include_context 'dealing_platform'

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

  it 'calculates correct payout amount for binaries' do
    market = build :market_overview, instrument_type: :binary
    position = build :position, size: 100, level: 0.8, market: market

    expect(position.profit_loss).to eq(125)
  end

  it 'can be updated' do
    payload = { limitLevel: 2.0, stopLevel: 1.0, trailingStop: false }
    put_result = { deal_reference: 'reference' }

    expect(session).to receive(:put).with('positions/otc/1', payload, IGMarkets::API_V2).and_return(put_result)

    expect(position.update(stop_level: 1, limit_level: 2)).to eq('reference')
  end

  it 'can be closed' do
    payload = { dealId: '1', direction: 'SELL', orderType: 'MARKET', size: 10.4, timeInForce: 'EXECUTE_AND_ELIMINATE' }
    delete_result = { deal_reference: 'reference' }

    expect(session).to receive(:delete).with('positions/otc', payload).and_return(delete_result)

    expect(position.close).to eq('reference')
  end

  it 'validates close attributes correctly' do
    attributes = { time_in_force: :execute_and_eliminate }

    close_position_proc = proc do |override_attributes = {}|
      position.close attributes.merge(override_attributes)
    end

    expect(session).to receive(:delete).exactly(3).times.and_return(deal_reference: 'reference')

    expect { close_position_proc.call }.to_not raise_error
    expect { close_position_proc.call order_type: :quote }.to raise_error(ArgumentError)
    expect { close_position_proc.call order_type: :quote, quote_id: 'a' }.to raise_error(ArgumentError)
    expect { close_position_proc.call order_type: :quote, level: 1 }.to raise_error(ArgumentError)
    expect { close_position_proc.call order_type: :quote, quote_id: 'a', level: 1 }.to_not raise_error
    expect { close_position_proc.call order_type: :limit }.to raise_error(ArgumentError)
    expect { close_position_proc.call order_type: :limit, level: 1 }.to_not raise_error
  end
end
