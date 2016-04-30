FactoryGirl.define do
  factory :historical_price_result_metadata, class: IGMarkets::HistoricalPriceResult::Metadata do
    allowance { build :historical_price_result_metadata_allowance }
    page_data { build :historical_price_result_metadata_page_data }
    size 1000
  end
end
