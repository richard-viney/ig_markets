describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    IGMarkets::CLI::Main.instance_variable_set :@dealing_platform, dealing_platform

    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints transactions from a recent number of days' do
    transactions = [build(:transaction)]

    expect(dealing_platform.account).to receive(:recent_transactions).with(3).and_return(transactions)

    expect { cli(days: 3).transactions }.to output(<<-END
+------------+-----------+------+------+------------+-------------+
|                          Transactions                           |
+------------+-----------+------+------+------------+-------------+
| Date       | Reference | Type | Size | Instrument | Profit/loss |
+------------+-----------+------+------+------------+-------------+
| 2015-06-23 | reference | Deal | +1   | instrument | US -1.00    |
+------------+-----------+------+------+------------+-------------+

Interest: US 0.00
Profit/loss: US -1.00
END
                                                  ).to_stdout
  end

  it 'prints transactions from a number of days and a start date' do
    start_date = Date.new 2015, 02, 15
    end_date = Date.new 2015, 02, 18

    expect(dealing_platform.account).to receive(:transactions_in_date_range).with(start_date, end_date).and_return([])

    expect { cli(days: 3, start_date: '2015-02-15').transactions }.to output(<<-END
+------+-----------+------+------+------------+-------------+
|                       Transactions                        |
+------+-----------+------+------+------------+-------------+
| Date | Reference | Type | Size | Instrument | Profit/loss |
+------+-----------+------+------+------------+-------------+
+------+-----------+------+------+------------+-------------+
END
                                                                            ).to_stdout
  end

  it 'prints transactions filtered by instrument' do
    transactions = [build(:transaction), build(:transaction, instrument_name: 'test 123')]

    expect(dealing_platform.account).to receive(:recent_transactions).with(3).and_return(transactions)

    expect { cli(days: 3, instrument: '123').transactions }.to output(<<-END
+------------+-----------+------+------+------------+-------------+
|                          Transactions                           |
+------------+-----------+------+------+------------+-------------+
| Date       | Reference | Type | Size | Instrument | Profit/loss |
+------------+-----------+------+------+------------+-------------+
| 2015-06-23 | reference | Deal | +1   | test 123   | US -1.00    |
+------------+-----------+------+------+------------+-------------+

Interest: US 0.00
Profit/loss: US -1.00
END
                                                                     ).to_stdout
  end
end
