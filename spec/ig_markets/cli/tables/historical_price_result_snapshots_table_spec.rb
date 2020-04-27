describe IGMarkets::CLI::Tables::HistoricalPriceResultSnapshotsTable do
  it 'prints prices' do
    prices = [build(:historical_price_result_snapshot)]

    expect(described_class.new(prices, title: 'A').to_s).to eql(<<~MSG.strip
      +-------------------------+------+-------+-----+------+
      |                          A                          |
      +-------------------------+------+-------+-----+------+
      | Date                    | Open | Close | Low | High |
      +-------------------------+------+-------+-----+------+
      | 2015-06-16 00:00:00 UTC |  100 |   100 | 100 |  100 |
      +-------------------------+------+-------+-----+------+
    MSG
                                                               )
  end
end
