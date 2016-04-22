describe IGMarkets::CLI::Watchlists do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli
    IGMarkets::CLI::Watchlists.new
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints watchlists' do
    watchlists = [build(:watchlist)]
    markets = [build(:market_overview)]

    expect(watchlists[0]).to receive(:markets).and_return(markets)
    expect(dealing_platform.watchlists).to receive(:all).and_return(watchlists)

    expect { cli.list }.to output(<<-END
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
|                                                       Markets (id: 2547731)                                                       |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
| Type       | EPIC               | Instrument      | Status    | Expiry | Bid   | Offer | High  | Low  | Change (net) | Change (%) |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
| Currencies | CS.D.EURUSD.CFD.IP | Spot FX EUR/USD | Tradeable |        | 100.0 |  99.0 | 110.0 | 90.0 |          #{'5.0'.green} |        #{'5.0'.green} |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
END
                                 ).to_stdout
  end

  it 'creates a watchlist' do
    watchlist = build :watchlist

    expect(dealing_platform.watchlists).to receive(:create).with('name', 'epic1', 'epic2').and_return(watchlist)

    expect { cli.create 'name', 'epic1', 'epic2' }.to output(<<-END
New watchlist ID: 2547731
END
                                                            ).to_stdout
  end

  it 'adds markets to a watchlist' do
    watchlist = build :watchlist

    expect(dealing_platform.watchlists).to receive(:[]).and_return(watchlist)
    expect(watchlist).to receive(:add_market).with('epic1')
    expect(watchlist).to receive(:add_market).with('epic2')

    cli.add_markets 'watchlist_id', 'epic1', 'epic2'
  end

  it 'removes markets from a watchlist' do
    watchlist = build :watchlist

    expect(dealing_platform.watchlists).to receive(:[]).and_return(watchlist)
    expect(watchlist).to receive(:remove_market).with('epic1')
    expect(watchlist).to receive(:remove_market).with('epic2')

    cli.remove_markets 'watchlist_id', 'epic1', 'epic2'
  end

  it 'deletes a watchlist' do
    watchlist = build :watchlist

    expect(dealing_platform.watchlists).to receive(:[]).and_return(watchlist)
    expect(watchlist).to receive(:delete).and_return(status: 'SUCCESS')

    cli.delete 'watchlist_id'
  end

  it 'reports an error when deleting a watchlist that does not exist' do
    expect(dealing_platform.watchlists).to receive(:[]).and_return(nil)

    expect { cli.delete 'watchlist_id' }.to raise_error('no watchlist with the specified ID')
  end
end
