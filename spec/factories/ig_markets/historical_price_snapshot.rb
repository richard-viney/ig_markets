FactoryGirl.define do
  factory :historical_price_snapshot, class: IGMarkets::HistoricalPriceSnapshot do
    close_price { build(:price) }
    high_price { build(:price) }
    last_traded_volume 100
    low_price { build(:price) }
    open_price { build(:price) }
    snapshot_time DateTime.new(2014, 10, 22, 18, 30, 45)
  end
end
