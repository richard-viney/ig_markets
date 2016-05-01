describe IGMarkets::DealingPlatform::WorkingOrderMethods do
  include_context 'dealing_platform'

  it 'can retrieve the current working orders' do
    orders = [build(:working_order)]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_V2).and_return(get_result)
    expect(dealing_platform.working_orders.all).to eq(orders)
  end

  it 'can retrieve a single working order' do
    orders = [build(:working_order, deal_id: '1')]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_V2).and_return(get_result)
    expect(dealing_platform.working_orders['1']).to eq(orders.first)
  end

  it 'can create a working order' do
    attributes = {
      currency_code: 'USD',
      direction: :buy,
      epic: 'CS.D.EURUSD.CFD.IP',
      good_till_date: Time.new(2015, 10, 30, 12, 59, 0, 0),
      level: 1.0,
      size: 2.0,
      type: :limit
    }

    payload = {
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

    expect(session).to receive(:post).with('workingorders/otc', payload, IGMarkets::API_V2).and_return(result)
    expect(dealing_platform.working_orders.create(attributes)).to eq(result.fetch(:deal_reference))
  end
end
