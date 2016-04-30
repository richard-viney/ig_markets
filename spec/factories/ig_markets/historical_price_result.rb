FactoryGirl.define do
  factory :historical_price_result, class: IGMarkets::HistoricalPriceResult do
    instrument_type :currencies
    metadata { build :historical_price_result_metadata }
    prices { [build(:historical_price_result_snapshot)] }
  end
end
