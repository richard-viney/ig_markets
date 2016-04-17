describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints transactions from a recent number of days' do
    transactions = [build(:account_transaction)]

    expect(dealing_platform.account).to receive(:recent_transactions).with(259_200).and_return(transactions)

    expect { cli(days: 3).transactions }.to output(<<-END
2015-06-23 reference: Deal, +1 of instrument, profit/loss: US -1.00

Totals for currency 'US':
  Interest: US 0.00
  Profit/loss: US -1.00
END
                                                  ).to_stdout
  end

  it 'prints transactions from a number of days and a start date' do
    start_date = Date.new 2015, 01, 15
    end_date = Date.new 2015, 01, 18

    expect(dealing_platform.account).to receive(:transactions_in_date_range).with(start_date, end_date).and_return([])

    expect { cli(days: 3, start_date: '2015-01-15').transactions }.to_not output.to_stdout
  end
end
