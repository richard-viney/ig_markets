describe IGMarkets::CLI::AccountsTable do
  it do
    accounts = [
      build(:account, balance: build(:account_balance, profit_loss: 20)),
      build(:account, balance: build(:account_balance, profit_loss: -20))
    ]

    expect(IGMarkets::CLI::AccountsTable.new(accounts).to_s).to eql(<<-END.strip
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
|                                                Accounts                                                 |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
| Name | ID    | Type | Currency | Status  | Preferred | Available  | Balance    | Margin   | Profit/loss |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
| CFD  | A1234 | CFD  | USD      | Enabled | Yes       | USD 500.00 | USD 500.00 | USD 0.00 |   #{'USD 20.00'.green} |
| CFD  | A1234 | CFD  | USD      | Enabled | Yes       | USD 500.00 | USD 500.00 | USD 0.00 |  #{'USD -20.00'.red} |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
END
                                                                   )
  end
end
