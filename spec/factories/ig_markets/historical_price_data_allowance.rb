FactoryGirl.define do
  factory :historical_price_data_allowance, class: IGMarkets::HistoricalPriceDataAllowance do
    allowance_expiry 100
    remaining_allowance 1000
    total_allowance 1000
  end
end
