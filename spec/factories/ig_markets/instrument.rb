FactoryGirl.define do
  factory :instrument, class: IGMarkets::Instrument do
    chart_code 'CODE'
    contract_size '+1'
    controlled_risk_allowed false
    country 'US'
    currencies { [build(:instrument_currency)] }
    epic 'CS.D.EURUSD.CFD.IP'
    expiry '20-DEC-40'
    expiry_details { build :instrument_expiry_details }
    force_open_allowed false
    limited_risk_premium { build :limited_risk_premium }
    lot_size 1000.0
    margin_deposit_bands { [build(:instrument_margin_deposit_band)] }
    margin_factor 0.01
    margin_factor_unit 'PERCENTAGE'
    market_id 'MARKET'
    name 'Instrument'
    news_code 'CODE'
    one_pip_means ''
    opening_hours { [build(:instrument_opening_hours)] }
    rollover_details { build :instrument_rollover_details }
    slippage_factor { build :instrument_slippage_factor }
    special_info %w[INFO]
    sprint_markets_maximum_expiry_time 100.0
    sprint_markets_minimum_expiry_time 10.0
    stops_limits_allowed true
    streaming_prices_available true
    type 'SHARES'
    unit 'SHARES'
    value_of_one_pip 'pip'
  end

  factory :instrument_currency, class: IGMarkets::Instrument::Currency do
    base_exchange_rate 1.5
    code 'USD'
    exchange_rate '1.5'
    is_default false
    symbol 'USD'
  end

  factory :instrument_expiry_details, class: IGMarkets::Instrument::ExpiryDetails do
    last_dealing_date '2022-12-20T23:59'
    settlement_info 'Info'
  end

  factory :instrument_margin_deposit_band, class: IGMarkets::Instrument::MarginDepositBand do
    currency 'USD'
    margin 0.01
    max 0.01
    min 0.01
  end

  factory :instrument_opening_hours, class: IGMarkets::Instrument::OpeningHours do
    close_time '5pm'
    open_time '8am'
  end

  factory :instrument_rollover_details, class: IGMarkets::Instrument::RolloverDetails do
    last_rollover_time ''
    rollover_info ''
  end

  factory :instrument_slippage_factor, class: IGMarkets::Instrument::SlippageFactor do
    unit 'USD'
    value 1
  end
end
