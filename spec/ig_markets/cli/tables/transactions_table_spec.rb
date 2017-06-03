describe IGMarkets::CLI::Tables::TransactionsTable do
  it 'prints transactions' do
    transactions = [
      build(:transaction),
      build(:transaction, instrument_name: 'ABC'),
      build(:transaction, instrument_name: 'DEF', profit_and_loss: 'US1.00')
    ]

    expect(described_class.new(transactions).to_s).to eql(<<-END.strip
+-------------------------+-------------------------+-----------+------+------------+------+------+-------+-------------+
|                                                     Transactions                                                      |
+-------------------------+-------------------------+-----------+------+------------+------+------+-------+-------------+
| Date                    | Open Date               | Reference | Type | Instrument | Size | Open | Close | Profit/loss |
+-------------------------+-------------------------+-----------+------+------------+------+------+-------+-------------+
| 2015-10-27 14:30:00 UTC | 2015-10-26 09:30:00 UTC | Reference | Deal | Instrument |   +1 |  0.8 |   0.8 |    #{ColorizedString['US -1.00'].red} |
| 2015-10-27 14:30:00 UTC | 2015-10-26 09:30:00 UTC | Reference | Deal | ABC        |   +1 |  0.8 |   0.8 |    #{ColorizedString['US -1.00'].red} |
| 2015-10-27 14:30:00 UTC | 2015-10-26 09:30:00 UTC | Reference | Deal | DEF        |   +1 |  0.8 |   0.8 |     #{ColorizedString['US 1.00'].green} |
+-------------------------+-------------------------+-----------+------+------------+------+------+-------+-------------+
END
                                                         )
  end
end
