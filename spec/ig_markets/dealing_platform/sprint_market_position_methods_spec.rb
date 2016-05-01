describe IGMarkets::DealingPlatform::SprintMarketPositionMethods do
  include_context 'dealing_platform'

  it 'can retrieve sprint market positions' do
    positions = [build(:sprint_market_position)]

    expect(session).to receive(:get)
      .with('positions/sprintmarkets', IGMarkets::API_V2)
      .and_return(sprint_market_positions: positions)

    expect(dealing_platform.sprint_market_positions.all).to eq(positions)
  end

  it 'can retrieve a single sprint market position' do
    positions = [build(:sprint_market_position)]

    expect(session).to receive(:get).twice
      .with('positions/sprintmarkets', IGMarkets::API_V2)
      .and_return(sprint_market_positions: positions)

    expect(dealing_platform.sprint_market_positions['DEAL']).to eq(positions.first)
    expect(dealing_platform.sprint_market_positions['UNKNOWN']).to be_nil
  end

  it 'can create a sprint market position' do
    attributes = {
      direction: :buy,
      epic: 'CS.D.EURUSD.CFD.IP',
      expiry_period: :five_minutes,
      size: 2.0
    }

    payload = {
      direction: 'BUY',
      epic: 'CS.D.EURUSD.CFD.IP',
      expiryPeriod: 'FIVE_MINUTES',
      size: 2.0
    }

    expect(session).to receive(:post).with('positions/sprintmarkets', payload).and_return(deal_reference: 'reference')
    expect(dealing_platform.sprint_market_positions.create(attributes)).to eq('reference')
  end
end
