describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'prints accounts' do
    accounts = [
      build(:account, balance: build(:account_balance, profit_loss: 20)),
      build(:account, balance: build(:account_balance, profit_loss: -20))
    ]

    expect(dealing_platform.account).to receive(:all).and_return(accounts)

    expect { cli.account }.to output(<<-END
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
|                                                Accounts                                                 |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
| Name | ID    | Type | Currency | Status  | Preferred | Available  | Balance    | Margin   | Profit/loss |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
| CFD  | A1234 | CFD  | USD      | Enabled | Yes       | USD 500.00 | USD 500.00 | USD 0.00 |   #{'USD 20.00'.green} |
| CFD  | A1234 | CFD  | USD      | Enabled | Yes       | USD 500.00 | USD 500.00 | USD 0.00 |  #{'USD -20.00'.red} |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
END
                                    ).to_stdout
  end
end
