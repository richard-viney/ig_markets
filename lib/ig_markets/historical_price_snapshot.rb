module IGMarkets
  class HistoricalPriceSnapshot
    include ActiveAttr::Model

    attribute :close_price, typecaster: proc { |attributes| Price.new attributes }
    attribute :high_price, typecaster: proc { |attributes| Price.new attributes }
    attribute :last_traded_volume, type: Float
    attribute :low_price, typecaster: proc { |attributes| Price.new attributes }
    attribute :open_price, typecaster: proc { |attributes| Price.new attributes }
    attribute :snapshot_time
  end
end
