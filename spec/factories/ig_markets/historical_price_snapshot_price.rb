FactoryGirl.define do
  factory :historical_price_snapshot_price, class: IGMarkets::HistoricalPriceSnapshot::Price do
    ask 101.0
    bid 99.0
    last_traded nil
  end
end
