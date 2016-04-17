describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: 'username', password: 'password', api_key: 'api-key' }.merge(arguments)
  end

  before do
    IGMarkets::CLI::Main.instance_variable_set :@dealing_platform, dealing_platform
  end

  it 'correctly signs in' do
    expect(dealing_platform).to receive(:sign_in).with('username', 'password', 'api-key', :production)

    IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
  end

  it 'reports a standard error' do
    expect(dealing_platform).to receive(:sign_in).and_raise('test')

    expect do
      IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
    end.to output("Error: test\n").to_stderr.and raise_error(SystemExit)
  end

  it 'reports a request failure' do
    expect(dealing_platform).to receive(:sign_in).and_raise(IGMarkets::RequestFailedError, 'test')

    expect do
      IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
    end.to output("Request failed: test\n").to_stderr.and raise_error(SystemExit)
  end
end
