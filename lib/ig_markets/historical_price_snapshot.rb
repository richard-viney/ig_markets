module IGMarkets
  class HistoricalPriceSnapshot < Model
    attribute :close_price, type: Price
    attribute :high_price, type: Price
    attribute :last_traded_volume, type: :float
    attribute :low_price, type: Price
    attribute :open_price, type: Price
    attribute :snapshot_time, type: :date_time, format: '%Y/%m/%d %H:%M:%S'
  end
end
