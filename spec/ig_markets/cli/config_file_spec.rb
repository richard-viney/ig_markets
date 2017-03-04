describe IGMarkets::CLI::ConfigFile do
  let(:config_file_contents) do
    {
      'profiles' => {
        'default' => { 'username' => 'A', 'password' => 'B', 'demo' => true },
        'my-profile' => { 'username' => 'C', 'password' => 'D' }
      }
    }
  end

  let(:config_file) { described_class.new config_file_contents }

  it "prepends the default profile's arguments to argv" do
    argv = ['command', '--argument']

    config_file.prepend_profile_arguments_to_argv argv

    expect(argv).to eq(%w(command --username=A --password=B --demo=true --argument))
  end

  it "prepends a specified profile's arguments to argv" do
    argv = ['command', '--argument', '--profile', 'my-profile']

    config_file.prepend_profile_arguments_to_argv argv

    expect(argv).to eq(%w(command --username=C --password=D --argument))
  end

  it 'finds the first config file that exists and loads it' do
    expect(File).to receive(:exist?).with('absent').and_return(false)
    expect(File).to receive(:exist?).with('present').and_return(true)
    expect(YAML).to receive(:load_file).with('present').and_return(config_file_contents)

    described_class.find 'absent', 'present', 'ignored'
  end
end
