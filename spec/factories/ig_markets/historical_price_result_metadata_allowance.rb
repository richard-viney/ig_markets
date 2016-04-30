FactoryGirl.define do
  factory :historical_price_result_metadata_allowance, class: IGMarkets::HistoricalPriceResult::Metadata::Allowance do
    allowance_expiry 1000
    remaining_allowance 4990
    total_allowance 5000
  end
end
