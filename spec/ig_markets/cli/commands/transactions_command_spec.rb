describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    allow(Date).to receive(:today).and_return(Date.new(2016, 1, 5))
  end

  it 'prints transactions from a recent number of days' do
    transactions = [build(:transaction)]

    expect(dealing_platform.account).to receive(:transactions).with(from: Date.new(2016, 1, 2)).and_return(transactions)

    expect { cli(days: 3, interest: true, sort_by: 'date').transactions }.to output(<<-END
#{IGMarkets::CLI::TransactionsTable.new transactions}

Interest: US 0.00
Profit/loss: US -1.00
END
                                                                                   ).to_stdout
  end

  it 'prints transactions from a number of days and a start date' do
    from = Date.new 2015, 02, 15
    to = Date.new 2015, 02, 18

    expect(dealing_platform.account).to receive(:transactions).with(from: from, to: to).and_return([])

    expect do
      cli(days: 3, from: '2015-02-15', interest: true).transactions
    end.to output("#{IGMarkets::CLI::TransactionsTable.new []}\n").to_stdout
  end

  it 'prints transactions filtered by instrument without interest transactions' do
    transactions = [
      build(:transaction, date_utc: Time.new(2015, 10, 28, 0, 0, 0, 0)),
      build(:transaction, instrument_name: 'Test 123', date_utc: Time.new(2015, 10, 28, 0, 0, 0, 0)),
      build(:transaction, instrument_name: 'Test 456', profit_and_loss: 'US1.00')
    ]

    expect(dealing_platform.account).to receive(:transactions).with(from: Date.new(2016, 1, 2)).and_return(transactions)

    expect { cli(days: 3, instrument: 'TEST', interest: false, sort_by: 'date').transactions }.to output(<<-END
#{IGMarkets::CLI::TransactionsTable.new [transactions[2], transactions[1]]}

Profit/loss: US 0.00
END
                                                                                                        ).to_stdout
  end
end
