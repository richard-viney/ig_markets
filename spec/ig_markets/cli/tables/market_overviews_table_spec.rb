describe IGMarkets::CLI::MarketOverviewsTable do
  it 'prints market overviews' do
    markets = [build(:market_overview, net_change: -1)]

    expect(IGMarkets::CLI::MarketOverviewsTable.new(markets).to_s).to eql(<<-END.strip
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
|                                                              Markets                                                              |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
| Type       | EPIC               | Instrument      | Status    | Expiry | Bid   | Offer | High  | Low  | Change (net) | Change (%) |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
| Currencies | CS.D.EURUSD.CFD.IP | Spot FX EUR/USD | Tradeable |        | 100.0 |  99.0 | 110.0 | 90.0 |         #{'-1.0'.red} |        #{'5.0'.green} |
+------------+--------------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
END
                                                                         )
  end
end
