FactoryGirl.define do
  factory :historical_price_result, class: IGMarkets::HistoricalPriceResult do
    allowance { build :historical_price_result_data_allowance }
    instrument_type :currencies
    prices { [build(:historical_price_result_snapshot)] }
  end
end
