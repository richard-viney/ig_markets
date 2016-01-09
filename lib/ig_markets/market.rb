module IGMarkets
  class Market < Model
    attribute :bid, type: :float
    attribute :delay_time, type: :float
    attribute :epic
    attribute :exchange_id
    attribute :expiry
    attribute :high, type: :float
    attribute :instrument_name
    attribute :instrument_type
    attribute :lot_size, type: :float
    attribute :low, type: :float
    attribute :market_status
    attribute :net_change, type: :float
    attribute :offer, type: :float
    attribute :percentage_change, type: :float
    attribute :scaling_factor, type: :float
    attribute :streaming_prices_available, type: :boolean
    attribute :update_time
    attribute :update_time_utc
  end
end
