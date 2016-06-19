describe IGMarkets::CLI::HistoricalPriceResultSnapshotsTable do
  it do
    prices = [build(:historical_price_result_snapshot)]

    expect(IGMarkets::CLI::HistoricalPriceResultSnapshotsTable.new(prices, title: 'A').to_s).to eql(<<-END.strip
+-------------------------+------+-------+-----+------+
|                          A                          |
+-------------------------+------+-------+-----+------+
| Date                    | Open | Close | Low | High |
+-------------------------+------+-------+-----+------+
| 2015-06-16 00:00:00 UTC |  100 |   100 | 100 |  100 |
+-------------------------+------+-------+-----+------+
END
                                                                                                   )
  end
end
