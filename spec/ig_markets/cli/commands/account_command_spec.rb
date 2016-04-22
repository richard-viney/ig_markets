describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints accounts' do
    accounts = [build(:account)]

    expect(dealing_platform.account).to receive(:all).and_return(accounts)

    expect { cli.account }.to output(<<-END
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
|                                                Accounts                                                 |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
| Name | ID    | Type | Currency | Status  | Preferred | Available  | Balance    | Margin   | Profit/loss |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
| CFD  | A1234 | CFD  | USD      | Enabled | Yes       | USD 500.00 | USD 500.00 | USD 0.00 |    USD 0.00 |
+------+-------+------+----------+---------+-----------+------------+------------+----------+-------------+
END
                                    ).to_stdout
  end
end
