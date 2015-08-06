module IGMarkets
  class MarketSnapshot < Model
    attribute :bid, type: :float
    attribute :binary_odds, type: :float
    attribute :controlled_risk_extra_spread, type: :float
    attribute :decimal_places_factor, type: :float
    attribute :delay_time, type: :float
    attribute :high, type: :float
    attribute :low, type: :float
    attribute :market_status
    attribute :net_change, type: :float
    attribute :offer, type: :float
    attribute :percentage_change, type: :float
    attribute :scaling_factor, type: :float
    attribute :update_time
  end
end
