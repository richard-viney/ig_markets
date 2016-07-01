describe IGMarkets::CLI::Main, :cli_command do
  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'prints accounts' do
    accounts = [build(:account), build(:account)]

    expect(dealing_platform.account).to receive(:all).and_return(accounts)

    expect { cli.account }.to output("#{IGMarkets::CLI::AccountsTable.new accounts}\n").to_stdout
  end
end
