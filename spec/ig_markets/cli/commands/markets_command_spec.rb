describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'prints markets' do
    markets = [build(:market), build(:market)]

    expect(dealing_platform.markets).to receive(:find).with('ABCDEF', '123456').and_return(markets)

    expect { cli.markets('ABCDEF', '123456') }.to output("#{IGMarkets::CLI::MarketsTable.new markets}\n").to_stdout
  end
end
