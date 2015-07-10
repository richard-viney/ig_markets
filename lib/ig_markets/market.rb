module IGMarkets
  class Market < Model
    attribute :bid, type: Float
    attribute :delay_time, type: Float
    attribute :epic
    attribute :exchange_id
    attribute :expiry
    attribute :high, type: Float
    attribute :instrument_name
    attribute :instrument_type
    attribute :lot_size, type: Float
    attribute :low, type: Float
    attribute :market_status
    attribute :net_change, type: Float
    attribute :offer, type: Float
    attribute :percentage_change, type: Float
    attribute :scaling_factor, type: Float
    attribute :streaming_prices_available, type: Boolean
    attribute :update_time
  end
end
