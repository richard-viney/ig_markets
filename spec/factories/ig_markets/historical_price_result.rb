FactoryGirl.define do
  factory :historical_price_result, class: IGMarkets::HistoricalPriceResult do
    instrument_type :currencies
    metadata { build :historical_price_result_metadata }
    prices { [build(:historical_price_result_snapshot)] }
  end

  factory :historical_price_result_metadata, class: IGMarkets::HistoricalPriceResult::Metadata do
    allowance { build :historical_price_result_metadata_allowance }
    page_data { build :historical_price_result_metadata_page_data }
    size 1000
  end

  factory :historical_price_result_metadata_allowance, class: IGMarkets::HistoricalPriceResult::Metadata::Allowance do
    allowance_expiry 1000
    remaining_allowance 4990
    total_allowance 5000
  end

  factory :historical_price_result_metadata_page_data, class: IGMarkets::HistoricalPriceResult::Metadata::PageData do
    page_number 1
    page_size 100
    total_pages 100
  end

  factory :historical_price_result_snapshot, class: IGMarkets::HistoricalPriceResult::Snapshot do
    close_price { build :historical_price_result_snapshot_price }
    high_price { build :historical_price_result_snapshot_price }
    last_traded_volume 100
    low_price { build :historical_price_result_snapshot_price }
    open_price { build :historical_price_result_snapshot_price }
    snapshot_time '2015/06/16 00:00:00'
    snapshot_time_utc '2015-06-16T00:00:00'
  end

  factory :historical_price_result_snapshot_price, class: IGMarkets::HistoricalPriceResult::Snapshot::Price do
    ask 101.0
    bid 99.0
    last_traded nil
  end
end
