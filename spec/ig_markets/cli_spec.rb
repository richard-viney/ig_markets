describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }
  let(:cli) do
    arguments = {
      username: 'username',
      password: 'password',
      api_key: 'api-key',
      query: 'q',
      market: 'm',
      days: 3,
      related: true,
      deal_reference: 'ref'
    }

    IGMarkets::CLI::Main.new([], arguments).tap do |cli|
      cli.class.instance_variable_set :@dealing_platform, dealing_platform
    end
  end

  it 'correctly signs in' do
    expect(dealing_platform).to receive(:sign_in).with('username', 'password', 'api-key', :production)

    IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
  end

  it 'reports a request failure' do
    expect(dealing_platform).to receive(:sign_in).and_raise(IGMarkets::RequestFailedError, 'test')

    expect do
      IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
    end.to output("ERROR: test\n").to_stdout.and raise_error(SystemExit)
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

    it 'prints activities' do
      activities = [build(:account_activity)]

      expect(dealing_platform.account).to receive(:recent_activities).with(259_200).and_return(activities)

      expect { cli.activities }.to output(<<-END
DIAAAAA4HDKPQEQ: +1 of CS.D.NZDUSD.CFD.IP, level: 0.664, result: Result
END
                                         ).to_stdout
    end

    it 'prints working orders' do
      expect(dealing_platform.working_orders).to receive(:all).and_return([build(:working_order)])

      expect { cli.orders }.to output(<<-END
deal_id: buy 1 of UA.D.AAPL.CASH.IP at 100.0, limit distance: 10, stop distance: 10, good till 2015-10-30 12:59:00 +0000
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

      expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

      expect { cli.confirmation }.to output(<<-END
deal_id: accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                           ).to_stdout
    end

    it 'prints a deal confirmation that was rejected' do
      deal_confirmation = build :deal_confirmation, deal_status: :rejected, reason: :unknown

      expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

      expect { cli.confirmation }.to output(<<-END
deal_id: rejected, reason: unknown, epic: CS.D.EURUSD.CFD.IP
END
                                           ).to_stdout
    end

    it 'searches for markets' do
      expect(dealing_platform.markets).to receive(:search).with('q').and_return([build(:market_overview)])
      expect { cli.search }.to output(<<-END
CS.D.EURUSD.CFD.IP: Spot FX EUR/USD, type: currencies, bid: 100.0 offer: 99.0
END
                                     ).to_stdout
    end

    it 'prints client sentiment' do
      sentiment = build(:client_sentiment)
      related_sentiments = [build(:client_sentiment, market_id: 'A'), build(:client_sentiment, market_id: 'B')]

      expect(dealing_platform.client_sentiment).to receive(:[]).with('m').and_return(sentiment)
      expect(sentiment).to receive(:related_sentiments).and_return(related_sentiments)

      expect { cli.sentiment }.to output(<<-END
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

    it 'prints transactions' do
      transactions = [build(:account_transaction)]

      expect(dealing_platform.account).to receive(:recent_transactions).with(259_200).and_return(transactions)

      expect { cli.transactions }.to output(<<-END
reference: 2015-06-23, Deal, +1 of instrument, profit/loss: US -1.00

Totals for currency 'US':
  Interest: US 0.00
  Profit/loss: US -1.00
END
                                           ).to_stdout
    end

    it 'prints watchlists' do
      watchlists = [build(:watchlist)]

      expect(watchlists[0]).to receive(:markets).and_return([build(:market_overview)])
      expect(dealing_platform.watchlists).to receive(:all).and_return(watchlists)

      expect { cli.watchlists }.to output(<<-END
2547731: Markets, editable: false, deleteable: false, default: false
  - CS.D.EURUSD.CFD.IP: Spot FX EUR/USD, type: currencies, bid: 100.0 offer: 99.0

END
                                         ).to_stdout
    end
  end
end
