describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints positions' do
    positions = [build(:position)]

    expect(dealing_platform.positions).to receive(:all).and_return(positions)

    expect { cli.positions }.to output(<<-END
deal_id: +10.4 of CS.D.EURUSD.CFD.IP at 100.0, profit/loss: USD 0.00
END
                                      ).to_stdout
  end
end
