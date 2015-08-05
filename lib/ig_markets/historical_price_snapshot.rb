module IGMarkets
  class HistoricalPriceSnapshot < Model
    attribute :close_price, typecaster: AttributeTypecasters.price
    attribute :high_price, typecaster: AttributeTypecasters.price
    attribute :last_traded_volume, typecaster: AttributeTypecasters.float
    attribute :low_price, typecaster: AttributeTypecasters.price
    attribute :open_price, typecaster: AttributeTypecasters.price
    attribute :snapshot_time, typecaster: AttributeTypecasters.date_time('%Y/%m/%d %H:%M:%S')
  end
end
