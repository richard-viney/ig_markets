describe IGMarkets::Validate do
  describe '.epic!' do
    let(:appl_epic) { 'UA.D.AAPL.CASH.IP' }
    let(:msft_epic) { 'UA.D.MSFT.CASH.IP' }
    let(:invalid_epic) { 'UA.D.AAPL.CASH.I#' }

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
  end

  describe '.historical_price_resolution!' do
    it 'accepts valid resolutions' do
      [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2, :hour_3, :hour_4,
       :day, :week, :month].each do |resolution|
        expect { IGMarkets::Validate.historical_price_resolution! resolution }.not_to raise_error
      end
    end

    it 'fails on invalid resolutions' do
      [nil, '', :invalid_type].each do |type|
        expect { IGMarkets::Validate.historical_price_resolution! type }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.order_type!' do
    it 'accepts valid types' do
      [:limit, :market, :quote].each do |type|
        expect { IGMarkets::Validate.order_type! type }.not_to raise_error
      end
    end

    it 'fails on invalid types' do
      [nil, '', :unknown].each do |type|
        expect { IGMarkets::Validate.order_type! type }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.sprint_market_expiry_period!' do
    it 'accepts valid expiry periods' do
      [:one_minute, :two_minutes, :five_minutes, :twenty_minutes, :sixty_minutes].each do |period|
        expect { IGMarkets::Validate.sprint_market_expiry_period! period }.not_to raise_error
      end
    end

    it 'fails on invalid expiry periods' do
      [nil, '', :thirteen_minutes].each do |period|
        expect { IGMarkets::Validate.sprint_market_expiry_period! period }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'position_time_in_force!' do
    it 'accepts valid options' do
      [:execute_and_eliminate, :fill_or_kill].each do |option|
        expect { IGMarkets::Validate.position_time_in_force! option }.not_to raise_error
      end
    end

    it 'fails on invalid options' do
      [nil, '', :unknown].each do |option|
        expect { IGMarkets::Validate.position_time_in_force! option }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.transaction_type!' do
    it 'accepts valid types' do
      [:all, :all_deal, :deposit, :withdrawal].each do |type|
        expect { IGMarkets::Validate.transaction_type! type }.not_to raise_error
      end
    end

    it 'fails on invalid types' do
      [nil, '', :invalid_type].each do |type|
        expect { IGMarkets::Validate.transaction_type! type }.to raise_error(ArgumentError)
      end
    end
  end
end
