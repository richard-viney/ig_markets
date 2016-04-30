FactoryGirl.define do
  factory :historical_price_result_snapshot_price, class: IGMarkets::HistoricalPriceResult::Snapshot::Price do
    ask 101.0
    bid 99.0
    last_traded nil
  end
end
