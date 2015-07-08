module IGMarkets
  class HistoricalPriceSnapshot
    include ActiveAttr::Model

    attribute :close_price, typecaster: AttributeTypecasters.price
    attribute :high_price, typecaster: AttributeTypecasters.price
    attribute :last_traded_volume, type: Float
    attribute :low_price, typecaster: AttributeTypecasters.price
    attribute :open_price, typecaster: AttributeTypecasters.price
    attribute :snapshot_time, typecaster: ->(value) { DateTime.strptime(value, '%Y/%m/%d %H:%M:%S') }
  end
end
