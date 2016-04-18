describe IGMarkets::CLI::Sprints do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Sprints.new [], arguments
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints sprint market positions' do
    sprint_market_positions = [build(:sprint_market_position)]

    expect(sprint_market_positions[0]).to receive(:seconds_till_expiry).and_return(125)
    expect(dealing_platform.sprint_market_positions).to receive(:all).and_return(sprint_market_positions)

    expect { cli.list }.to output(<<-END
deal_id: USD 120.50 on FM.D.FTSE.FTSE.IP to be above 110.1 in 2:05, payout: USD 210.80
END
                                 ).to_stdout
  end

  it 'creates a sprint market position' do
    arguments = { direction: 'buy', epic: 'CS.D.EURUSD.CFD.IP', expiry_period: '5', size: '10' }

    expect(dealing_platform.sprint_market_positions).to receive(:create).with(
      direction: 'buy', epic: 'CS.D.EURUSD.CFD.IP', expiry_period: :five_minutes, size: '10').and_return('ref')

    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).create
  end
end
