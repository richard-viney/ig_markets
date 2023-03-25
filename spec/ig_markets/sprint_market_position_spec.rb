describe IGMarkets::SprintMarketPosition do
  let(:platform) { IGMarkets::DealingPlatform.new }

  before do
    allow(Time).to receive(:now).and_return(Time.new(2015, 1, 1, 0, 0, 0, 0))
  end

  it 'calculates seconds till expiry' do
    sprint_market_position = build(:sprint_market_position, expiry_time: Time.new(2015, 1, 1, 0, 0, 5, 0))

    expect(sprint_market_position.seconds_till_expiry).to eq(5)
    expect(sprint_market_position.expired?).to be(false)
  end

  it 'reports when it has expired' do
    sprint_market_position = build(:sprint_market_position, expiry_time: Time.new(1, 1, 1, 0, 0, 0, 0))

    expect(sprint_market_position.expired?).to be(true)
  end
end
