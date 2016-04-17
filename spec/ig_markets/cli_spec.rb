describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  before do
    IGMarkets::CLI::Main.instance_variable_set :@dealing_platform, dealing_platform
  end

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: 'username', password: 'password', api_key: 'api-key' }.merge(arguments)
  end

  it 'correctly signs in' do
    expect(dealing_platform).to receive(:sign_in).with('username', 'password', 'api-key', :production)

    IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
  end

  it 'reports a standard error' do
    expect(dealing_platform).to receive(:sign_in).and_raise('test')

    expect do
      IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
    end.to output("Error: test\n").to_stdout.and raise_error(SystemExit)
  end

  it 'reports a request failure' do
    expect(dealing_platform).to receive(:sign_in).and_raise(IGMarkets::RequestFailedError, 'test')

    expect do
      IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
    end.to output("Request failed: test\n").to_stdout.and raise_error(SystemExit)
  end

  describe 'a signed in session' do
    before do
      expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
    end

    it 'prints accounts' do
      expect(dealing_platform.account).to receive(:all).and_return([build(:account)])

      expect { cli.account }.to output(<<-END
Account 'CFD':
  ID:           A1234
  Type:         CFD
  Currency:     USD
  Status:       ENABLED
  Available:    USD 500.00
  Balance:      USD 500.00
  Margin:       USD 0.00
  Profit/loss:  USD 0.00
END
                                      ).to_stdout
    end

    it 'prints activities from a recent number of days' do
      activities = [build(:account_activity)]

      expect(dealing_platform.account).to receive(:recent_activities).with(259_200).and_return(activities)

      expect { cli(days: 3).activities }.to output(<<-END
2015-12-20 DIAAAAA4HDKPQEQ: +1 of CS.D.NZDUSD.CFD.IP, level: 0.664, result: Result
END
                                                  ).to_stdout
    end

    it 'prints activities from a number of days and a start date' do
      start_date = Date.new 2015, 01, 15
      end_date = Date.new 2015, 01, 18

      expect(dealing_platform.account).to receive(:activities_in_date_range).with(start_date, end_date).and_return([])

      expect { cli(days: 3, start_date: '2015-01-15').activities }.to_not output.to_stdout
    end

    it 'prints working orders' do
      expect(dealing_platform.working_orders).to receive(:all).and_return([build(:working_order)])

      expect { cli.orders }.to output(<<-END
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

      cli = IGMarkets::CLI::Orders.new [], arguments
      deal_confirmation = build :deal_confirmation
      attributes = arguments.merge good_till_date: Time.new(2016, 5, 15, 9, 45, 0, 0)

      expect(dealing_platform.working_orders).to receive(:create).with(attributes).and_return('ref')
      expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

      expect { cli.create }.to output(<<-END
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

      cli = IGMarkets::CLI::Orders.new [], arguments

      expect { cli.create }.to raise_error(
        StandardError, 'invalid --good-till-date, use format "yyyy-mm-ddThh:mm(+|-)zz:zz"')
    end

    it 'updates a working order' do
      arguments = {
        good_till_date: '2016-05-15T09:45+00:00',
        level: '1.024',
        limit_distance: '20',
        stop_distance: '30'
      }

      cli = IGMarkets::CLI::Orders.new [], arguments
      working_order = build :working_order
      deal_confirmation = build :deal_confirmation
      attributes = arguments.merge good_till_date: Time.new(2016, 5, 15, 9, 45, 0, 0)

      expect(dealing_platform.working_orders).to receive(:[]).with(working_order.deal_id).and_return(working_order)
      expect(working_order).to receive(:update).with(attributes).and_return('ref')
      expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

      expect { cli.update working_order.deal_id }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                                           ).to_stdout
    end

    it 'updates a working order and removes its good_till_date' do
      arguments = { good_till_date: nil }

      cli = IGMarkets::CLI::Orders.new [], arguments
      working_order = build :working_order
      deal_confirmation = build :deal_confirmation

      expect(dealing_platform.working_orders).to receive(:[]).with(working_order.deal_id).and_return(working_order)
      expect(working_order).to receive(:update).with(arguments).and_return('ref')
      expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

      expect { cli.update working_order.deal_id }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                                           ).to_stdout
    end

    it 'deletes a working order' do
      cli = IGMarkets::CLI::Orders.new [], {}
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

    it 'prints positions' do
      expect(dealing_platform.positions).to receive(:all).and_return([build(:position)])

      expect { cli.positions }.to output(<<-END
deal_id: +10.4 of CS.D.EURUSD.CFD.IP at 100.0, profit/loss: USD 0.00
END
                                        ).to_stdout
    end

    it 'prints a deal confirmation that was accepted' do
      deal_confirmation = build :deal_confirmation

      expect(dealing_platform).to receive(:deal_confirmation).with('deal_id').and_return(deal_confirmation)

      expect { cli.confirmation deal_confirmation.deal_id }.to output(<<-END
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                                                     ).to_stdout
    end

    it 'prints a deal confirmation that was rejected' do
      deal_confirmation = build :deal_confirmation, deal_status: :rejected, reason: :unknown

      expect(dealing_platform).to receive(:deal_confirmation).with('deal_id').and_return(deal_confirmation)

      expect { cli.confirmation deal_confirmation.deal_id }.to output(<<-END
Deal confirmation: deal_id, rejected, reason: unknown, epic: CS.D.EURUSD.CFD.IP
END
                                                                     ).to_stdout
    end

    it 'searches for markets' do
      expect(dealing_platform.markets).to receive(:search).with('EURUSD').and_return([build(:market_overview)])

      expect { cli.search 'EURUSD' }.to output(<<-END
CS.D.EURUSD.CFD.IP: Spot FX EUR/USD, type: currencies, bid: 100.0 offer: 99.0
END
                                              ).to_stdout
    end

    it 'prints client sentiment' do
      sentiment = build(:client_sentiment)
      related_sentiments = [build(:client_sentiment, market_id: 'A'), build(:client_sentiment, market_id: 'B')]

      expect(dealing_platform.client_sentiment).to receive(:[]).with('query').and_return(sentiment)
      expect(sentiment).to receive(:related_sentiments).and_return(related_sentiments)

      expect { cli(related: true).sentiment 'query' }.to output(<<-END
EURUSD: longs: 60.0%, shorts: 40.0%
A: longs: 60.0%, shorts: 40.0%
B: longs: 60.0%, shorts: 40.0%
END
                                                               ).to_stdout
    end

    it 'prints sprint market positions' do
      sprint_market_positions = [build(:sprint_market_position)]

      expect(sprint_market_positions[0]).to receive(:seconds_till_expiry).and_return(125)
      expect(dealing_platform.sprint_market_positions).to receive(:all).and_return(sprint_market_positions)

      expect { cli.sprints }.to output(<<-END
deal_id: USD 120.50 on FM.D.FTSE.FTSE.IP to be above 110.1 in 2:05, payout: USD 210.80
END
                                      ).to_stdout
    end

    it 'creates a sprint market position' do
      cli = IGMarkets::CLI::Sprints.new [], direction: 'buy', epic: 'CS.D.EURUSD.CFD.IP', expiry_period: '5', size: '10'

      expect(dealing_platform.sprint_market_positions).to receive(:create).with(
        direction: 'buy', epic: 'CS.D.EURUSD.CFD.IP', expiry_period: :five_minutes, size: '10').and_return('ref')
      expect(dealing_platform).to receive(:deal_confirmation).and_return(build(:deal_confirmation))

      expect { cli.create }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                     ).to_stdout
    end

    it 'prints transactions from a recent number of days' do
      transactions = [build(:account_transaction)]

      expect(dealing_platform.account).to receive(:recent_transactions).with(259_200).and_return(transactions)

      expect { cli(days: 3).transactions }.to output(<<-END
2015-06-23 reference: Deal, +1 of instrument, profit/loss: US -1.00

Totals for currency 'US':
  Interest: US 0.00
  Profit/loss: US -1.00
END
                                                    ).to_stdout
    end

    it 'prints transactions from a number of days and a start date' do
      start_date = Date.new 2015, 01, 15
      end_date = Date.new 2015, 01, 18

      expect(dealing_platform.account).to receive(:transactions_in_date_range).with(start_date, end_date).and_return([])

      expect { cli(days: 3, start_date: '2015-01-15').transactions }.to_not output.to_stdout
    end
  end
end
