describe IGMarkets::CLI::ConfigFile do
  let(:config_file_contents) do
    [
      '--username=USERNAME',
      '--password PASSWORD # The password',
      '# A comment',
      '--demo'
    ]
  end

  it 'prepends arguments to argv' do
    config_file = IGMarkets::CLI::ConfigFile.new config_file_contents

    argv = ['command', '--argument']

    config_file.prepend_arguments_to_argv argv

    expect(argv).to eq(%w(command --username=USERNAME --password PASSWORD --demo --argument))
  end

  it 'finds the first config file that exists and opens it' do
    expect(File).to receive(:exist?).with('absent').and_return(false)
    expect(File).to receive(:exist?).with('present').and_return(true)
    expect(File).to receive(:readlines).with('present').and_return(config_file_contents)

    config_file = IGMarkets::CLI::ConfigFile.find 'absent', 'present', 'ignored'

    expect(config_file.arguments).to eq(['--username=USERNAME', '--password', 'PASSWORD', '--demo'])
  end
end
