module IGMarkets
  class Market < Model
    attribute :bid, typecaster: AttributeTypecasters.float
    attribute :delay_time, typecaster: AttributeTypecasters.float
    attribute :epic
    attribute :exchange_id
    attribute :expiry
    attribute :high, typecaster: AttributeTypecasters.float
    attribute :instrument_name
    attribute :instrument_type
    attribute :lot_size, typecaster: AttributeTypecasters.float
    attribute :low, typecaster: AttributeTypecasters.float
    attribute :market_status
    attribute :net_change, typecaster: AttributeTypecasters.float
    attribute :offer, typecaster: AttributeTypecasters.float
    attribute :percentage_change, typecaster: AttributeTypecasters.float
    attribute :scaling_factor, typecaster: AttributeTypecasters.float
    attribute :streaming_prices_available, typecaster: AttributeTypecasters.boolean
    attribute :update_time
  end
end
