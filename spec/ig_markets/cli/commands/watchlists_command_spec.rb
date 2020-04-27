describe IGMarkets::CLI::Watchlists, :cli_command do
  def cli
    IGMarkets::CLI::Watchlists.new
  end

  it 'prints watchlists' do
    watchlists = [build(:watchlist)]
    markets = [build(:market_overview)]

    expect(dealing_platform.watchlists).to receive(:all).and_return(watchlists)
    expect(watchlists.first).to receive(:markets).and_return(markets)

    expect { cli.list }
      .to output("#{IGMarkets::CLI::Tables::MarketOverviewsTable.new(markets, title: 'Markets (id: 2547731)')}\n")
      .to_stdout
  end

  it 'creates a new watchlist' do
    watchlist = build :watchlist

    expect(dealing_platform.watchlists).to receive(:create).with('name', 'epic1', 'epic2').and_return(watchlist)

    expect { cli.create 'name', 'epic1', 'epic2' }.to output(<<~MSG
      New watchlist ID: 2547731
    MSG
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
