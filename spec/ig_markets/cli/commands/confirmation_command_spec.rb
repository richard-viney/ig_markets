describe IGMarkets::CLI::Main, :cli_command do
  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'prints a deal confirmation' do
    expect(described_class).to receive(:report_deal_confirmation).with('reference')

    cli.confirmation 'reference'
  end
end
