module IGMarkets
  class MarketSnapshot < Model
    attribute :bid, Float
    attribute :binary_odds, Float
    attribute :controlled_risk_extra_spread, Float
    attribute :decimal_places_factor, Float
    attribute :delay_time, Float
    attribute :high, Float
    attribute :low, Float
    attribute :market_status, Symbol, allowed_values: Market.defined_attributes[:market_status][:allowed_values]
    attribute :net_change, Float
    attribute :offer, Float
    attribute :percentage_change, Float
    attribute :scaling_factor, Float
    attribute :update_time
  end
end
