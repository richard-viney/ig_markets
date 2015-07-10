describe IGMarkets::Validate do
  let(:appl_epic)    { 'UA.D.AAPL.CASH.IP' }
  let(:msft_epic)    { 'UA.D.MSFT.CASH.IP' }
  let(:invalid_epic) { 'UA.D.AAPL.CASH.I#' }

  it 'accepts valid currency codes' do
    expect { IGMarkets::Validate.currency_code! 'USD' }.not_to raise_error
  end

  it 'fails on invalid currency codes' do
    expect { IGMarkets::Validate.currency_code! 'ABCD' }.to raise_error(ArgumentError)
  end

  it 'accepts valid epics' do
    [appl_epic, [appl_epic, msft_epic]].each do |epics|
      expect { IGMarkets::Validate.epic! epics }.not_to raise_error
    end
  end

  it 'fails on invalid epics' do
    [invalid_epic, [appl_epic, invalid_epic]].each do |epics|
      expect { IGMarkets::Validate.epic! epics }.to raise_error(ArgumentError)
    end
  end

  it 'accepts valid historical price resolutions' do
    IGMarkets::Validate::HISTORICAL_PRICE_RESOLUTIONS.each do |resolution|
      expect { IGMarkets::Validate.historical_price_resolution! resolution }.not_to raise_error
    end
  end

  it 'fails on invalid historical price resolutions' do
    [nil, '', :invalid_type].each do |type|
      expect { IGMarkets::Validate.historical_price_resolution! type }.to raise_error(ArgumentError)
    end
  end

  it 'accepts valid transaction types' do
    IGMarkets::Validate::TRANSACTION_TYPES.each do |type|
      expect { IGMarkets::Validate.transaction_type! type }.not_to raise_error
    end
  end

  it 'fails on invalid transaction types' do
    [nil, '', :invalid_type].each do |type|
      expect { IGMarkets::Validate.transaction_type! type }.to raise_error(ArgumentError)
    end
  end
end
