describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'prints a deal confirmation' do
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli.confirmation 'ref'
  end
end
