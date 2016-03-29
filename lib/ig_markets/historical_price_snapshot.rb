module IGMarkets
  class HistoricalPriceSnapshot < Model
    attribute :close_price, Price
    attribute :high_price, Price
    attribute :last_traded_volume, Float
    attribute :low_price, Price
    attribute :open_price, Price
    attribute :snapshot_time, DateTime, format: '%Y/%m/%d %H:%M:%S'
  end
end
