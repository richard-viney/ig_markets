describe IGMarkets::DealingPlatform::SprintMarketPositionMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve the current sprint market positions' do
    positions = [build(:sprint_market_position)]

    expect(session).to receive(:get)
      .with('positions/sprintmarkets', IGMarkets::API_VERSION_1)
      .and_return(sprint_market_positions: positions)

    expect(platform.sprint_market_positions.all).to eq(positions)
  end
end
