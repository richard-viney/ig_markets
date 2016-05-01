describe IGMarkets::CLI::Orders do
  include_context 'cli_command'

  def cli(arguments = {})
    IGMarkets::CLI::Orders.new [], arguments
  end

  it 'prints working orders' do
    working_orders = [build(:working_order)]

    expect(dealing_platform.working_orders).to receive(:all).and_return(working_orders)

    expect { cli.list }.to output(<<-END
+-------------------------+-------------------+----------+-------+-----------+------+-------+----------------+---------------+-------------------------+---------+
|                                                                         Working orders                                                                         |
+-------------------------+-------------------+----------+-------+-----------+------+-------+----------------+---------------+-------------------------+---------+
| Created date            | EPIC              | Currency | Type  | Direction | Size | Level | Limit distance | Stop distance | Good till date          | Deal ID |
+-------------------------+-------------------+----------+-------+-----------+------+-------+----------------+---------------+-------------------------+---------+
| 2014-10-20 13:30:03 UTC | UA.D.AAPL.CASH.IP | USD      | Limit | Buy       |    1 | 100.0 |             10 |            10 | 2015-10-30 12:59:00 UTC | DEAL    |
+-------------------------+-------------------+----------+-------+-----------+------+-------+----------------+---------------+-------------------------+---------+
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

    attributes = arguments.merge good_till_date: Time.new(2016, 5, 15, 9, 45, 0, 0)

    expect(dealing_platform.working_orders).to receive(:create).with(attributes).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).create
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
    attributes = arguments.merge good_till_date: Time.new(2016, 5, 15, 9, 45, 0, 0)

    expect(dealing_platform.working_orders).to receive(:[]).with(working_order.deal_id).and_return(working_order)
    expect(working_order).to receive(:update).with(attributes).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).update working_order.deal_id
  end

  it 'updates a working order and removes its good_till_date' do
    arguments = { good_till_date: nil }

    working_order = build :working_order

    expect(dealing_platform.working_orders).to receive(:[]).with(working_order.deal_id).and_return(working_order)
    expect(working_order).to receive(:update).with(arguments).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).update working_order.deal_id
  end

  it 'deletes a working order' do
    working_order = build :working_order

    expect(dealing_platform.working_orders).to receive(:[]).with(working_order.deal_id).and_return(working_order)
    expect(working_order).to receive(:delete).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli.delete working_order.deal_id
  end
end
