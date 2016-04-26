FactoryGirl.define do
  factory :historical_price_result_snapshot, class: IGMarkets::HistoricalPriceResult::Snapshot, parent: :model do
    close_price { build :historical_price_result_price }
    high_price { build :historical_price_result_price }
    last_traded_volume 100
    low_price { build :historical_price_result_price }
    open_price { build :historical_price_result_price }
    snapshot_time '2015/06/16 00:00:00'
  end
end
