describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  it 'prints performance' do
    activities = [build(:activity, description: 'Position/s closed: 1', epic: 'CS.D.EURUSD.CFD.IP'),
                  build(:activity, description: 'Position/s closed: 2', epic: 'CS.D.EURUSD.CFD.IP'),
                  build(:activity, description: 'Position/s closed: 3', epic: 'CS.D.AUDUSD.CFD.IP'),
                  build(:activity, description: 'Position/s closed: 4', epic: 'CS.D.AUDUSD.CFD.IP')]

    transactions = [build(:transaction, reference: '1', profit_and_loss: 'US10.00'),
                    build(:transaction, reference: '2', profit_and_loss: 'US20.00'),
                    build(:transaction, reference: '3', profit_and_loss: 'US-1.00'),
                    build(:transaction, reference: '4', profit_and_loss: 'US-2.00')]

    performances = [{ epic: 'CS.D.AUDUSD.CFD.IP', transactions: transactions[0..1], profit_loss: -3 },
                    { epic: 'CS.D.EURUSD.CFD.IP', transactions: transactions[2..3], profit_loss: 30 }]

    expect(dealing_platform.account).to receive(:activities).and_return(activities)
    expect(dealing_platform.account).to receive(:transactions).and_return(transactions)

    expect { cli(days: 10).performance }.to output(<<-END
#{IGMarkets::CLI::PerformancesTable.new performances}

Note: this table only shows the profit/loss made from dealing, it does not include interest payments, dividends, or
      other adjustments that may have occurred over this period.

Total: #{'US 27.00'.green}
END
                                                  ).to_stdout
  end
end
