describe IGMarkets::CLI::Tables::AccountsTable do
  it 'prints accounts' do
    accounts = [
      build(:account, balance: build(:account_balance, profit_loss: 20)),
      build(:account, balance: build(:account_balance, profit_loss: -20))
    ]

    expect(described_class.new(accounts).to_s).to eql(<<-END.strip
+------+---------+------+----------+---------+-----------+------------+------------+----------+-------------+
|                                                 Accounts                                                  |
+------+---------+------+----------+---------+-----------+------------+------------+----------+-------------+
| Name | ID      | Type | Currency | Status  | Preferred | Available  | Balance    | Margin   | Profit/loss |
+------+---------+------+----------+---------+-----------+------------+------------+----------+-------------+
| CFD  | ACCOUNT | CFD  | USD      | Enabled | Yes       | USD 500.00 | USD 500.00 | USD 0.00 |   #{ColorizedString['USD 20.00'].green} |
| CFD  | ACCOUNT | CFD  | USD      | Enabled | Yes       | USD 500.00 | USD 500.00 | USD 0.00 |  #{ColorizedString['USD -20.00'].red} |
+------+---------+------+----------+---------+-----------+------------+------------+----------+-------------+
END
                                                     )
  end
end
