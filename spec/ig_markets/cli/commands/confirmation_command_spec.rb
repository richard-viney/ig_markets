describe IGMarkets::CLI::Main, :cli_command do
  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'prints a deal confirmation' do
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli.confirmation 'ref'
  end
end
