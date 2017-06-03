describe IGMarkets::CLI::Tables::MarketOverviewsTable do
  it 'prints market overviews' do
    markets = [build(:market_overview, net_change: -1)]

    expect(described_class.new(markets).to_s).to eql(<<-END.strip
+--------------------+------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
|                                                              Markets                                                              |
+--------------------+------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
| EPIC               | Type       | Instrument      | Status    | Expiry | Bid   | Offer | High  | Low  | Change (net) | Change (%) |
+--------------------+------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
| CS.D.EURUSD.CFD.IP | Currencies | Spot FX EUR/USD | Tradeable |        | 100.0 |  99.0 | 110.0 | 90.0 |         #{ColorizedString['-1.0'].red} |        #{ColorizedString['5.0'].green} |
+--------------------+------------+-----------------+-----------+--------+-------+-------+-------+------+--------------+------------+
END
                                                    )
  end
end
