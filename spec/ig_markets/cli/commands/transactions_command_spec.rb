describe IGMarkets::CLI::Main, :cli_command do
  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    allow(Time).to receive(:now).and_return(Time.new(2016, 1, 5))
  end

  it 'prints transactions from a recent number of days' do
    transactions = [build(:transaction)]

    expect(dealing_platform.account).to receive(:transactions).with(from: Time.new(2016, 1, 2)).and_return(transactions)

    expect { cli(days: 3, interest: true, sort_by: 'date').transactions }.to output(<<-END
#{IGMarkets::CLI::TransactionsTable.new transactions}

Interest: US 0.00
Profit/loss: US -1.00
END
                                                                                   ).to_stdout
  end

  it 'prints transactions from a number of days and a start time' do
    from = Time.new 2015, 2, 15, 6, 0, 0
    to = Time.new 2015, 2, 18, 6, 0, 0

    expect(dealing_platform.account).to receive(:transactions).with(from: from, to: to).and_return([])

    expect do
      cli(days: 3, from: '2015-02-15T06:00:00', interest: true).transactions
    end.to output("#{IGMarkets::CLI::TransactionsTable.new []}\n").to_stdout
  end

  it 'prints transactions filtered by instrument without interest transactions' do
    transactions = [
      build(:transaction, date_utc: Time.new(2015, 10, 28, 0, 0, 0, 0)),
      build(:transaction, instrument_name: 'Test 123', date_utc: Time.new(2015, 10, 28, 0, 0, 0, 0)),
      build(:transaction, instrument_name: 'Test 456', profit_and_loss: 'US1.00')
    ]

    expect(dealing_platform.account).to receive(:transactions).with(from: Time.new(2016, 1, 2)).and_return(transactions)

    expect { cli(days: 3, instrument: 'TEST', interest: false, sort_by: 'date').transactions }.to output(<<-END
#{IGMarkets::CLI::TransactionsTable.new [transactions[2], transactions[1]]}

Profit/loss: US 0.00
END
                                                                                                        ).to_stdout
  end
end
