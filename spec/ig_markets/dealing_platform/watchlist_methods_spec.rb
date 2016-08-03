describe IGMarkets::DealingPlatform::WatchlistMethods, :dealing_platform do
  it 'retrieves the current watchlists' do
    watchlists = [build(:watchlist)]

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: watchlists)
    expect(dealing_platform.watchlists.all).to eq(watchlists)
  end

  it 'retrieves the markets for a watchlist' do
    markets = [build(:market_overview)]

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: [{ id: 1 }])
    expect(session).to receive(:get).with('watchlists/1').and_return(markets: markets)
    expect(dealing_platform.watchlists['1'].markets).to eq(markets)
  end

  it 'creates a new watchlist' do
    watchlist_id = '1000'
    name = 'New Watchlist'
    epics = ['ABCDEF']

    expect(session).to receive(:post)
      .with('watchlists', name: name, epics: epics)
      .and_return(watchlist_id: watchlist_id, status: 'SUCCESS')

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: [{ id: watchlist_id }])

    expect(dealing_platform.watchlists.create(name, epics)).to eq(IGMarkets::Watchlist.new(id: watchlist_id))
  end
end
