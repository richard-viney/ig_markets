module IGMarkets
  class MarketSnapshot
    include ActiveAttr::Model

    attribute :bid, type: Float
    attribute :binary_odds, type: Float
    attribute :controlled_risk_extra_spread, type: Float
    attribute :decimal_places_factor, type: Float
    attribute :delay_time, type: Float
    attribute :high, type: Float
    attribute :low, type: Float
    attribute :market_status
    attribute :net_change, type: Float
    attribute :offer, type: Float
    attribute :percentage_change, type: Float
    attribute :scaling_factor, type: Float
    attribute :update_time
  end
end
