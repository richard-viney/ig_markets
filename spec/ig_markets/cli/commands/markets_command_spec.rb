describe IGMarkets::CLI::Main, :cli_command do
  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'prints markets' do
    markets = [build(:market), build(:market)]

    expect(dealing_platform.markets).to receive(:find).with('ABCDEF', '123456').and_return(markets)

    expect do
      cli.markets('ABCDEF', '123456')
    end.to output("#{IGMarkets::CLI::Tables::MarketsTable.new markets}\n").to_stdout
  end
end
