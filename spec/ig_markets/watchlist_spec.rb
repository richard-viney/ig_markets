describe IGMarkets::Watchlist, :dealing_platform do
  let(:watchlist) { dealing_platform_model build(:watchlist, id: '1') }

  it 'deletes itself' do
    result = { status: 'SUCCESS' }

    expect(session).to receive(:delete).with('watchlists/1').and_return(result)

    expect(watchlist.delete).to eq(result)
  end

  it 'adds a new market' do
    result = { status: 'SUCCESS' }

    expect(session).to receive(:put).with('watchlists/1', epic: 'ABCDEF').and_return(result)

    expect(watchlist.add_market('ABCDEF')).to eq(result)
  end

  it 'removes a market' do
    result = { status: 'SUCCESS' }

    expect(session).to receive(:delete).with('watchlists/1/ABCDEF').and_return(result)

    expect(watchlist.remove_market('ABCDEF')).to eq(result)
  end
end
