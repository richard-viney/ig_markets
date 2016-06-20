describe IGMarkets::CLI::PerformancesTable do
  it 'prints performances' do
    performances = [{ epic: 'CS.D.GBPUSD.MINI.IP', transactions: [build(:transaction)], profit_loss: 100 },
                    { epic: 'CS.D.AUDUSD.MINI.IP', transactions: [build(:transaction)], profit_loss: -10 }]

    expect(IGMarkets::CLI::PerformancesTable.new(performances).to_s).to eql(<<-END.strip
+---------------------+-------------------+-------------+
|                  Dealing performance                  |
+---------------------+-------------------+-------------+
| EPIC                | # of closed deals | Profit/loss |
+---------------------+-------------------+-------------+
| CS.D.GBPUSD.MINI.IP |                 1 |   #{'US 100.00'.green} |
| CS.D.AUDUSD.MINI.IP |                 1 |   #{'US -10.00'.red} |
+---------------------+-------------------+-------------+
END
                                                                           )
  end
end
