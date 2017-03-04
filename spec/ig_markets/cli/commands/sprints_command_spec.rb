describe IGMarkets::CLI::Sprints, :cli_command do
  def cli(arguments = {})
    IGMarkets::CLI::Sprints.new [], arguments
  end

  it 'prints sprint market positions' do
    sprint_market_positions = [build(:sprint_market_position), build(:sprint_market_position, strike_level: 99)]
    markets = [build(:market, instrument: build(:instrument, epic: 'FM.D.FTSE.FTSE.IP'))]

    expect(dealing_platform.sprint_market_positions).to receive(:all).and_return(sprint_market_positions)
    expect(dealing_platform.markets).to receive(:find).with(['FM.D.FTSE.FTSE.IP']).and_return(markets)

    sprint_market_positions.each do |sprint_market_position|
      expect(sprint_market_position).to receive(:seconds_till_expiry).twice.and_return(125)
    end

    table = IGMarkets::CLI::Tables::SprintMarketPositionsTable.new sprint_market_positions, markets: markets

    expect { cli.list }.to output("#{table}\n").to_stdout
  end

  it 'creates a sprint market position' do
    arguments = { direction: 'buy', epic: 'CS.D.EURUSD.CFD.IP', expiry_period: :five_minutes, size: '10' }

    expect(dealing_platform.sprint_market_positions).to receive(:create).with(arguments).and_return('reference')

    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('reference')

    cli(arguments.merge(expiry_period: '5')).create
  end
end
