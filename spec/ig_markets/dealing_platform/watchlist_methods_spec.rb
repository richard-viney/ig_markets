describe IGMarkets::DealingPlatform::WatchlistMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve the watchlists' do
    watchlists = [build(:watchlist)]

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: watchlists)
    expect(platform.watchlists.all).to eq(watchlists)
  end

  it 'can retrieve the markets for a watchlist' do
    markets = [build(:market_overview)]

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: [{ id: 1 }])
    expect(session).to receive(:get).with('watchlists/1').and_return(markets: markets)
    expect(platform.watchlists['1'].markets).to eq(markets)
  end

  it 'can create a watchlist' do
    watchlist_id = '1000'
    name = 'New Watchlist'
    epics = ['ABCDEF']

    expect(session).to receive(:post)
      .with('watchlists', name: name, epics: epics)
      .and_return(watchlist_id: watchlist_id, status: 'SUCCESS')

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: [{ id: watchlist_id }])

    expect(platform.watchlists.create(name, epics)).to eq(IGMarkets::Watchlist.new(id: watchlist_id))
  end

  it 'can delete a watchlist' do
    watchlist_id = '1000'

    result = { status: 'SUCCESS' }

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: [{ id: watchlist_id }])
    expect(session).to receive(:delete).with("watchlists/#{watchlist_id}").and_return(result)

    expect(platform.watchlists[watchlist_id].delete).to eq(result)
  end

  it 'can add a market to a watchlist' do
    watchlist_id = '1000'
    epic = 'ABCDEF'

    result = { status: 'SUCCESS' }

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: [{ id: watchlist_id }])
    expect(session).to receive(:put).with("watchlists/#{watchlist_id}", epic: epic).and_return(result)

    expect(platform.watchlists[watchlist_id].add_market(epic)).to eq(result)
  end

  it 'can remove a market from a watchlist' do
    watchlist_id = '1000'
    epic = 'ABCDEF'

    result = { status: 'SUCCESS' }

    expect(session).to receive(:get).with('watchlists').and_return(watchlists: [{ id: watchlist_id }])
    expect(session).to receive(:delete).with("watchlists/#{watchlist_id}/#{epic}").and_return(result)

    expect(platform.watchlists[watchlist_id].remove_market(epic)).to eq(result)
  end
end
