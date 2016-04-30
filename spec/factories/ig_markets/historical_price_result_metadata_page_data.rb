FactoryGirl.define do
  factory :historical_price_result_metadata_page_data, class: IGMarkets::HistoricalPriceResult::Metadata::PageData do
    page_number 1
    page_size 100
    total_pages 100
  end
end
