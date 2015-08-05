module IGMarkets
  class MarketSnapshot < Model
    attribute :bid, typecaster: AttributeTypecasters.float
    attribute :binary_odds, typecaster: AttributeTypecasters.float
    attribute :controlled_risk_extra_spread, typecaster: AttributeTypecasters.float
    attribute :decimal_places_factor, typecaster: AttributeTypecasters.float
    attribute :delay_time, typecaster: AttributeTypecasters.float
    attribute :high, typecaster: AttributeTypecasters.float
    attribute :low, typecaster: AttributeTypecasters.float
    attribute :market_status
    attribute :net_change, typecaster: AttributeTypecasters.float
    attribute :offer, typecaster: AttributeTypecasters.float
    attribute :percentage_change, typecaster: AttributeTypecasters.float
    attribute :scaling_factor, typecaster: AttributeTypecasters.float
    attribute :update_time
  end
end
