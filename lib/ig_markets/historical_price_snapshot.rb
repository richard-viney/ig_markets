module IGMarkets
  class HistoricalPriceSnapshot < Model
    attribute :close_price, type: :price
    attribute :high_price, type: :price
    attribute :last_traded_volume, type: :float
    attribute :low_price, type: :price
    attribute :open_price, type: :price
    attribute :snapshot_time, type: :date_time, format: '%Y/%m/%d %H:%M:%S'
  end
end
