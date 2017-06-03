describe IGMarkets::CLI::Main, :cli_command do
  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    allow(Time).to receive(:now).and_return(Time.new(2016, 1, 15))
  end

  it 'prints performance' do
    eur_usd = 'CS.D.EURUSD.CFD.IP'
    aud_usd = 'CS.D.AUDUSD.CFD.IP'

    activities = [build(:activity, description: 'Position/s closed: 1', epic: eur_usd),
                  build(:activity, description: 'Position/s closed: 2', epic: eur_usd),
                  build(:activity, description: 'Position/s closed: 3', epic: aud_usd),
                  build(:activity, description: 'Position/s closed: 4', epic: aud_usd)]

    transactions = [build(:transaction, reference: '1', profit_and_loss: 'US10.00'),
                    build(:transaction, reference: '2', profit_and_loss: 'US20.00'),
                    build(:transaction, reference: '3', profit_and_loss: 'US-1.00'),
                    build(:transaction, reference: '4', profit_and_loss: 'US-2.00')]

    markets = [build(:market, instrument: build(:instrument, epic: eur_usd, name: 'EUR/USD')),
               build(:market, instrument: build(:instrument, epic: aud_usd, name: 'AUD/USD'))]

    expect(dealing_platform.account).to receive(:activities).with(from: Time.new(2016, 1, 5)).and_return(activities)
    expect(dealing_platform.account).to receive(:transactions).with(from: Time.new(2016, 1, 5)).and_return(transactions)
    expect(dealing_platform.markets).to receive(:find).with(aud_usd, eur_usd).and_return(markets)

    performances = [{ epic: aud_usd, instrument_name: 'AUD/USD', transactions: transactions[0..1], profit_loss: -3 },
                    { epic: eur_usd, instrument_name: 'EUR/USD', transactions: transactions[2..3], profit_loss: 30 }]

    expect { cli(days: 10).performance }.to output(<<-END
#{IGMarkets::CLI::Tables::PerformancesTable.new performances}

Note: this table only shows the profit/loss made from dealing, it does not include interest payments,
      dividends, or other adjustments that may have occurred over this period.

Total: #{ColorizedString['US 27.00'].green}
END
                                                  ).to_stdout
  end
end
