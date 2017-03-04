describe IGMarkets::CLI::Tables::SprintMarketPositionsTable do
  it 'prints sprint market positions' do
    sprint_market_positions = [build(:sprint_market_position), build(:sprint_market_position, strike_level: 99)]
    markets = [build(:market, instrument: build(:instrument, epic: 'FM.D.FTSE.FTSE.IP'))]

    sprint_market_positions.each do |sprint_market_position|
      expect(sprint_market_position).to receive(:seconds_till_expiry).and_return(125)
    end

    table = described_class.new(sprint_market_positions, markets: markets)

    expect(table.to_s).to eql(<<-END.strip
+-------------------+-----------+------------+--------------+---------+-------------------+------------+---------+
|                                            Sprint market positions                                             |
+-------------------+-----------+------------+--------------+---------+-------------------+------------+---------+
| EPIC              | Direction | Size       | Strike level | Current | Expires in (m:ss) | Payout     | Deal ID |
+-------------------+-----------+------------+--------------+---------+-------------------+------------+---------+
| FM.D.FTSE.FTSE.IP | Buy       | USD 120.50 |        110.1 |    99.5 |              2:05 | #{'USD 210.80'.red} | DEAL    |
| FM.D.FTSE.FTSE.IP | Buy       | USD 120.50 |         99.0 |    99.5 |              2:05 | #{'USD 210.80'.green} | DEAL    |
+-------------------+-----------+------------+--------------+---------+-------------------+------------+---------+
END
                             )
  end
end
