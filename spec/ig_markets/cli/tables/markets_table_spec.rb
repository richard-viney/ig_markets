describe IGMarkets::CLI::Tables::MarketsTable do
  it 'prints markets' do
    markets = [build(:market)]

    expect(described_class.new(markets).to_s).to eql(<<-END.strip
+--------------------+--------+------------+-----------+------------+-------+-------+-------+------+--------------+------------+
|                                                           Markets                                                            |
+--------------------+--------+------------+-----------+------------+-------+-------+-------+------+--------------+------------+
| EPIC               | Type   | Instrument | Status    | Expiry     | Bid   | Offer | High  | Low  | Change (net) | Change (%) |
+--------------------+--------+------------+-----------+------------+-------+-------+-------+------+--------------+------------+
| CS.D.EURUSD.CFD.IP | Shares | Instrument | Tradeable | 2040-12-20 | 100.0 |  99.0 | 110.0 | 90.0 |         #{ColorizedString['10.0'].green} |       #{ColorizedString['10.0'].green} |
+--------------------+--------+------------+-----------+------------+-------+-------+-------+------+--------------+------------+
END
                                                    )
  end
end
