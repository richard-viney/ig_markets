describe IGMarkets::CLI::Main, :cli_command do
  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'opens a console' do
    expect(Pry).to receive(:start)

    cli.console
  end
end
