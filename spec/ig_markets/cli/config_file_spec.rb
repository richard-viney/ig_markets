describe IGMarkets::CLI::ConfigFile do
  it 'reads and parses the file passed to initialize' do
    config_file_contents = [
      '--username=USERNAME',
      '--password PASSWORD # The password',
      '# A comment',
      '--demo'
    ]

    expect(File).to receive(:readlines).with('test').and_return(config_file_contents)

    config_file = IGMarkets::CLI::ConfigFile.new 'test'

    expect(config_file.arguments).to eq(['--username=USERNAME', '--password', 'PASSWORD', '--demo'])
  end

  before do
    allow(Dir).to receive(:pwd).and_return('pwd')
    allow(Dir).to receive(:home).and_return('home')
  end

  it 'finds a config file in the working directory' do
    expect(File).to receive(:exist?).with('pwd/.ig_markets').and_return(true)

    expect(IGMarkets::CLI::ConfigFile).to receive(:new).with('pwd/.ig_markets')

    IGMarkets::CLI::ConfigFile.find
  end

  it 'finds a config file in the home directory' do
    expect(File).to receive(:exist?).with('pwd/.ig_markets').and_return(false)
    expect(File).to receive(:exist?).with('home/.ig_markets').and_return(true)

    expect(IGMarkets::CLI::ConfigFile).to receive(:new).with('home/.ig_markets')

    IGMarkets::CLI::ConfigFile.find
  end

  it 'handles not finding a config file' do
    expect(File).to receive(:exist?).with('pwd/.ig_markets').and_return(false)
    expect(File).to receive(:exist?).with('home/.ig_markets').and_return(false)

    expect(IGMarkets::CLI::ConfigFile.find).to be_nil
  end
end
