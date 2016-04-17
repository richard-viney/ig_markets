describe IGMarkets::CLI::Orders do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Orders.new [], arguments
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints working orders' do
    working_orders = [build(:working_order)]

    expect(dealing_platform.working_orders).to receive(:all).and_return(working_orders)

    expect { cli.list }.to output(<<-END
deal_id: buy 1 of UA.D.AAPL.CASH.IP at 100.0, limit distance: 10, stop distance: 10, good till 2015-10-30 12:59 +0000
END
                                 ).to_stdout
  end

  it 'creates a working order' do
    arguments = {
      currency_code: 'USD',
      direction: 'buy',
      epic: 'CS.D.EURUSD.CFD.IP',
      good_till_date: '2016-05-15T09:45+00:00',
      level: '1.024',
      size: '1',
      type: 'limit'
    }

    deal_confirmation = build :deal_confirmation
    attributes = arguments.merge good_till_date: Time.new(2016, 5, 15, 9, 45, 0, 0)

    expect(dealing_platform.working_orders).to receive(:create).with(attributes).and_return('ref')
    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

    expect { cli(arguments).create }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                              ).to_stdout
  end

  it 'reports an error creating a working order with an invalid good_till_date' do
    arguments = {
      currency_code: 'USD',
      direction: 'buy',
      epic: 'CS.D.EURUSD.CFD.IP',
      good_till_date: 'invalid',
      level: '1.024',
      size: '1',
      type: 'limit'
    }

    expect { cli(arguments).create }.to raise_error(
      StandardError, 'invalid good_till_date, use format "yyyy-mm-ddThh:mm(+|-)zz:zz"')
  end

  it 'updates a working order' do
    arguments = {
      good_till_date: '2016-05-15T09:45+00:00',
      level: '1.024',
      limit_distance: '20',
      stop_distance: '30'
    }

    working_order = build :working_order
    deal_confirmation = build :deal_confirmation
    attributes = arguments.merge good_till_date: Time.new(2016, 5, 15, 9, 45, 0, 0)

    expect(dealing_platform.working_orders).to receive(:[]).with(working_order.deal_id).and_return(working_order)
    expect(working_order).to receive(:update).with(attributes).and_return('ref')
    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

    expect { cli(arguments).update working_order.deal_id }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                                                    ).to_stdout
  end

  it 'updates a working order and removes its good_till_date' do
    arguments = { good_till_date: nil }

    working_order = build :working_order
    deal_confirmation = build :deal_confirmation

    expect(dealing_platform.working_orders).to receive(:[]).with(working_order.deal_id).and_return(working_order)
    expect(working_order).to receive(:update).with(arguments).and_return('ref')
    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

    expect { cli(arguments).update working_order.deal_id }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                                                    ).to_stdout
  end

  it 'deletes a working order' do
    working_order = build :working_order
    deal_confirmation = build :deal_confirmation

    expect(dealing_platform.working_orders).to receive(:[]).with(working_order.deal_id).and_return(working_order)
    expect(working_order).to receive(:delete).and_return('ref')
    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

    expect { cli.delete working_order.deal_id }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                                         ).to_stdout
  end
end
