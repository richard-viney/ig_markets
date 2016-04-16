describe IGMarkets::DealingPlatform::WorkingOrderMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve the current working orders' do
    orders = [build(:working_order)]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_V2).and_return(get_result)
    expect(platform.working_orders.all).to eq(orders)
  end

  it 'can retrieve a single working order' do
    orders = [build(:working_order, deal_id: 'id')]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_V2).and_return(get_result)
    expect(platform.working_orders['id']).to eq(orders[0])
  end

  it 'can create a working order' do
    attributes = {
      currency_code: 'USD',
      direction: :buy,
      epic: 'CS.D.EURUSD.CFD.IP',
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
      guaranteedStop: false,
      level: 1.0,
      size: 2.0,
      timeInForce: 'GOOD_TILL_CANCELLED',
      type: 'LIMIT'
    }

    result = { deal_reference: 'reference' }

    expect(session).to receive(:post).with('workingorders/otc', payload, IGMarkets::API_V2).and_return(result)
    expect(platform.working_orders.create(attributes)).to eq(result.fetch(:deal_reference))
  end

  it 'can delete a working order' do
    orders = [build(:working_order, deal_id: '1')]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    del_result = { deal_reference: 'reference' }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_V2).and_return(get_result)
    expect(session).to receive(:delete).with('workingorders/otc/1', {}, IGMarkets::API_V1).and_return(del_result)

    expect(platform.working_orders['1'].delete).to eq('reference')
  end

  it 'can update a working order' do
    orders = [build(:working_order, deal_id: '1')]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    payload = {
      goodTillDate: '2015/10/30 12:59',
      level: 1.03,
      limitDistance: 20,
      stopDistance: 30,
      timeInForce: 'GOOD_TILL_DATE',
      type: 'LIMIT'
    }

    put_result = { deal_reference: 'reference' }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_V2).and_return(get_result)
    expect(session).to receive(:put).with('workingorders/otc/1', payload, IGMarkets::API_V1).and_return(put_result)
    expect(platform.working_orders['1'].update(level: 1.03, limit_distance: 20, stop_distance: 30)).to eq('reference')
  end
end
