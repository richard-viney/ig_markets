describe IGMarkets::CLI::PerformancesTable do
  it 'prints performances' do
    performances = [{ epic: 'ABCDEF', instrument_name: 'ABC', transactions: [build(:transaction)], profit_loss: 10 },
                    { epic: '123456', instrument_name: '123', transactions: [build(:transaction)], profit_loss: -5 }]

    expect(IGMarkets::CLI::PerformancesTable.new(performances).to_s).to eql(<<-END.strip
+--------+-----------------+-------------------+-------------+
|                    Dealing performance                     |
+--------+-----------------+-------------------+-------------+
| EPIC   | Instrument name | # of closed deals | Profit/loss |
+--------+-----------------+-------------------+-------------+
| ABCDEF | ABC             |                 1 |    #{'US 10.00'.green} |
| 123456 | 123             |                 1 |    #{'US -5.00'.red} |
+--------+-----------------+-------------------+-------------+
END
                                                                           )
  end
end
