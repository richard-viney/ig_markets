describe IGMarkets::Format do
  it 'formats prices correctly' do
    {
      [120.4122, 'USD'] => '120.4122',
      [-1340, 'USD'] => '-1340.0000',
      [6440, 'JPY'] => '6440.00  ',
      [-5209.40, '¥'] => '-5209.40  ',
      [nil, nil] => ''
    }.each do |args, result|
      expect(IGMarkets::Format.price(*args)).to eq(result)
    end
  end

  it 'formats currencies correctly' do
    {
      [120.4, 'USD'] => 'USD 120.40',
      [-1340, 'USD'] => 'USD -1340.00',
      [6440, 'JPY'] => 'JPY 6440',
      [-5200, '¥'] => '¥ -5200',
      [nil, nil] => ''
    }.each do |args, result|
      expect(IGMarkets::Format.currency(*args)).to eq(result)
    end
  end

  it 'formats seconds correctly' do
    {
      5 => '0:05',
      55 => '0:55',
      555 => '9:15',
      5555 => '1:32:35'
    }.each do |seconds, result|
      expect(IGMarkets::Format.seconds(seconds)).to eq(result)
    end
  end
end
