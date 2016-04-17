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
Account 'CFD':
  ID:           A1234
  Type:         CFD
  Currency:     USD
  Status:       ENABLED
  Available:    USD 500.00
  Balance:      USD 500.00
  Margin:       USD 0.00
  Profit/loss:  USD 0.00
END
                                    ).to_stdout
  end
end
