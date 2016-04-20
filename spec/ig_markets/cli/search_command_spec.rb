describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'searches for markets' do
    markets = [build(:market_overview)]

    expect(dealing_platform.markets).to receive(:search).with('EURUSD').and_return(markets)

    expect { cli.search 'EURUSD' }.to output(<<-END
+--------------------+-----------------+------------+-----+-------+
|                             Markets                             |
+--------------------+-----------------+------------+-----+-------+
| EPIC               | Instrument      | Type       | Bid | Offer |
+--------------------+-----------------+------------+-----+-------+
| CS.D.EURUSD.CFD.IP | Spot FX EUR/USD | currencies | 100 |    99 |
+--------------------+-----------------+------------+-----+-------+
END
                                            ).to_stdout
  end
end
