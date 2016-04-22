describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'searches for markets' do
    markets = [build(:market_overview, net_change: -1)]

    expect(dealing_platform.markets).to receive(:search).with('EURUSD').and_return(markets)

    expect { cli.search 'EURUSD' }.to output(<<-END
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
|                                                              Markets                                                              |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
| Type       | EPIC               | Instrument      | Status    | Expiry | Bid   | Offer | High  | Low  | Change (net) | Change (%) |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
| Currencies | CS.D.EURUSD.CFD.IP | Spot FX EUR/USD | Tradeable |        | 100.0 |  99.0 | 110.0 | 90.0 |         #{'-1.0'.red} |        #{'5.0'.green} |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
END
                                            ).to_stdout
  end
end
