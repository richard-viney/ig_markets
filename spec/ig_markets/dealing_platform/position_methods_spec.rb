describe IGMarkets::DealingPlatform::PositionMethods, :dealing_platform do
  let(:positions) { [build(:position, deal_id: '1')] }
  let(:get_result) do
    {
      positions: positions.map(&:attributes).map do |attributes|
        {
          market: attributes[:market],
          position: attributes
        }
      end
    }
  end

  it 'retrieves the current positions' do
    expect(session).to receive(:get).with('positions', IGMarkets::API_V2).and_return(get_result)

    expect(dealing_platform.positions.all).to eq(positions)
  end

  it 'retrieves a single position' do
    expect(session).to receive(:get).with('positions', IGMarkets::API_V2).and_return(get_result)

    expect(dealing_platform.positions[positions.first.deal_id]).to eq(positions.first)
  end

  it 'returns nil for an unknown deal ID' do
    expect(session).to receive(:get).with('positions', IGMarkets::API_V2).and_return(get_result)

    expect(dealing_platform.positions['UNKNOWN']).to be nil
  end

  it 'creates a new position' do
    attributes = {
      currency_code: 'USD',
      direction: :buy,
      epic: 'CS.D.EURUSD.CFD.IP',
      size: 2.0
    }

    body = {
      currencyCode: 'USD',
      direction: 'BUY',
      epic: 'CS.D.EURUSD.CFD.IP',
      expiry: '-',
      forceOpen: false,
      guaranteedStop: false,
      orderType: 'MARKET',
      size: 2.0,
      timeInForce: 'EXECUTE_AND_ELIMINATE'
    }

    result = { deal_reference: 'reference' }

    expect(session).to receive(:post).with('positions/otc', body, IGMarkets::API_V2).and_return(result)
    expect(dealing_platform.positions.create(attributes)).to eq(result.fetch(:deal_reference))
  end

  it 'validates position creation attributes' do
    create_position = proc do |override_attributes = {}|
      attributes = {
        currency_code: 'USD',
        direction: :buy,
        epic: 'CS.D.EURUSD.CFD.IP',
        size: 2.0,
        time_in_force: :execute_and_eliminate
      }.merge override_attributes

      dealing_platform.positions.create attributes
    end

    expect(session).to receive(:post).exactly(10).times.and_return(deal_reference: 'reference')

    expect { create_position.call }.to_not raise_error

    expect { create_position.call currency_code: nil }
      .to raise_error(ArgumentError, 'currency_code attribute must be set')

    expect { create_position.call order_type: :quote }
      .to raise_error(ArgumentError, 'set quote_id if and only if order_type is :quote')
    expect { create_position.call order_type: :quote, quote_id: 'a' }
      .to raise_error(ArgumentError, 'set level if and only if order_type is :limit or :quote')
    expect { create_position.call order_type: :quote, level: 1 }
      .to raise_error(ArgumentError, 'set quote_id if and only if order_type is :quote')
    expect { create_position.call order_type: :limit }
      .to raise_error(ArgumentError, 'set level if and only if order_type is :limit or :quote')
    expect { create_position.call order_type: :limit, level: 1 }.to_not raise_error
    expect { create_position.call order_type: :quote, quote_id: 'a', level: 1 }.to_not raise_error

    expect { create_position.call trailing_stop: true, stop_level: 1 }
      .to raise_error(ArgumentError, 'do not set stop_level when trailing_stop is true')
    expect { create_position.call trailing_stop: true }
      .to raise_error(ArgumentError, 'set stop_distance when trailing_stop is true')
    expect { create_position.call trailing_stop: true, stop_distance: 1 }
      .to raise_error(ArgumentError, 'set trailing_stop_increment when trailing_stop is true')
    expect { create_position.call trailing_stop: false, trailing_stop_increment: 1 }
      .to raise_error(ArgumentError, 'do not set trailing_stop_increment when trailing_stop is false')
    expect { create_position.call trailing_stop: true, stop_distance: 1, trailing_stop_increment: 1 }.not_to raise_error

    expect { create_position.call limit_distance: 1, limit_level: 1 }
      .to raise_error(ArgumentError, 'set only one of limit_level and limit_distance')
    expect { create_position.call limit_distance: 1 }.not_to raise_error
    expect { create_position.call limit_level: 1 }.not_to raise_error

    expect { create_position.call stop_distance: 1, stop_level: 1 }
      .to raise_error(ArgumentError, 'set only one of stop_level and stop_distance')
    expect { create_position.call stop_distance: 1 }.not_to raise_error
    expect { create_position.call stop_level: 1 }.not_to raise_error

    expect { create_position.call guaranteed_stop: true }
      .to raise_error(ArgumentError, 'set exactly one of stop_level or stop_distance when guaranteed_stop is true')
    expect { create_position.call guaranteed_stop: true, stop_distance: 1 }.not_to raise_error
    expect { create_position.call guaranteed_stop: true, stop_level: 1 }.not_to raise_error
  end
end
