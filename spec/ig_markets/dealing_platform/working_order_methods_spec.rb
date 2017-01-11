describe IGMarkets::DealingPlatform::WorkingOrderMethods, :dealing_platform do
  it 'retrieves the current working orders' do
    orders = [build(:working_order)]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_V2).and_return(get_result)
    expect(dealing_platform.working_orders.all).to eq(orders)
  end

  it 'retrieves a single working order' do
    orders = [build(:working_order, deal_id: '1')]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_V2).and_return(get_result)
    expect(dealing_platform.working_orders['1']).to eq(orders.first)
  end

  it 'creates a new working order' do
    attributes = {
      currency_code: 'USD',
      direction: :buy,
      epic: 'CS.D.EURUSD.CFD.IP',
      good_till_date: Time.new(2015, 10, 30, 12, 59, 0, 0),
      level: 1.0,
      size: 2.0,
      type: :limit
    }

    body = {
      currencyCode: 'USD',
      direction: 'BUY',
      epic: 'CS.D.EURUSD.CFD.IP',
      expiry: '-',
      forceOpen: false,
      goodTillDate: '2015/10/30 12:59:00',
      guaranteedStop: false,
      level: 1.0,
      size: 2.0,
      timeInForce: 'GOOD_TILL_DATE',
      type: 'LIMIT'
    }

    result = { deal_reference: 'reference' }

    expect(session).to receive(:post).with('workingorders/otc', body, IGMarkets::API_V2).and_return(result)
    expect(dealing_platform.working_orders.create(attributes)).to eq(result.fetch(:deal_reference))
  end

  it 'raises when creating a working order without required attributes' do
    expect { dealing_platform.working_orders.create({}) }
      .to raise_error(ArgumentError, 'currency_code attribute must be set')
  end

  it 'raises when creating a working order with both a limit distance and a limit level' do
    attributes = {
      currency_code: 'USD',
      direction: :buy,
      epic: 'CS.D.EURUSD.CFD.IP',
      level: 1.0,
      size: 2.0,
      type: :limit,
      limit_distance: 100,
      limit_level: 1.1
    }

    expect { dealing_platform.working_orders.create attributes }
      .to raise_error(ArgumentError, 'do not specify both limit_distance and limit_level options')
  end

  it 'raises when creating a working order with both a stop distance and a stop level' do
    attributes = {
      currency_code: 'USD',
      direction: :buy,
      epic: 'CS.D.EURUSD.CFD.IP',
      level: 1.0,
      size: 2.0,
      type: :limit,
      stop_distance: 100,
      stop_level: 0.9
    }

    expect { dealing_platform.working_orders.create attributes }
      .to raise_error(ArgumentError, 'do not specify both stop_distance and stop_level options')
  end
end
