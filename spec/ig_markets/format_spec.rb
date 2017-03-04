describe IGMarkets::Format do
  it 'formats levels' do
    {
      120.41224 => '120.4122',
      -1340 => '-1340.0',
      -5209.4 => '-5209.4',
      nil => ''
    }.each do |level, result|
      expect(described_class.level(level)).to eq(result)
    end
  end

  it 'formats currencies' do
    {
      [120.4, 'USD'] => 'USD 120.40',
      [-1340, 'USD'] => 'USD -1340.00',
      [6440, 'JPY'] => 'JPY 6440',
      [-5200, '¥'] => '¥ -5200',
      [nil, nil] => ''
    }.each do |args, result|
      expect(described_class.currency(*args)).to eq(result)
    end
  end

  it 'formats colored currencies' do
    {
      [120.4, 'USD'] => 'USD 120.40'.green,
      [-1340, 'USD'] => 'USD -1340.00'.red,
      [6440, 'JPY'] => 'JPY 6440'.green,
      [-5200, '¥'] => '¥ -5200'.red,
      [nil, nil] => ''
    }.each do |args, result|
      expect(described_class.colored_currency(*args)).to eq(result)
    end
  end

  it 'formats seconds' do
    {
      5 => '0:05',
      55 => '0:55',
      555 => '9:15',
      5555 => '1:32:35'
    }.each do |seconds, result|
      expect(described_class.seconds(seconds)).to eq(result)
    end
  end

  it 'formats symbols' do
    expect(described_class.symbol(:one)).to eq('One')
    expect(described_class.symbol(:two_three)).to eq('Two three')
  end
end
