describe IGMarkets::CLI::Tables::PerformancesTable do
  it 'prints performances' do
    performances = [{ epic: 'ABCDEF', instrument_name: 'ABC', transactions: [build(:transaction)], profit_loss: 10 },
                    { epic: '123456', instrument_name: '123', transactions: [build(:transaction)], profit_loss: -5 }]

    expect(described_class.new(performances).to_s).to eql(<<~MSG.strip
      +--------+-----------------+-------------------+-------------+
      |                    Dealing performance                     |
      +--------+-----------------+-------------------+-------------+
      | EPIC   | Instrument name | # of closed deals | Profit/loss |
      +--------+-----------------+-------------------+-------------+
      | ABCDEF | ABC             |                 1 |    #{ColorizedString['US 10.00'].green} |
      | 123456 | 123             |                 1 |    #{ColorizedString['US -5.00'].red} |
      +--------+-----------------+-------------------+-------------+
    MSG
                                                         )
  end
end
