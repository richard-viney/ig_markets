FactoryGirl.define do
  factory :instrument_currency, class: IGMarkets::Instrument::Currency do
    base_exchange_rate 1.5
    code 'USD'
    exchange_rate '1.5'
    is_default false
    symbol 'USD'
  end
end
