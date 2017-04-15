module IGMarkets
  # Contains an overview of a market's state. Returned by {Position#market} and {WorkingOrder#market}.
  class MarketOverview < Model
    attribute :bid, Float
    attribute :delay_time, Float
    attribute :epic, String, regex: Regex::EPIC
    attribute :exchange_id
    attribute :expiry, String, nil_if: %w[- DFB]
    attribute :high, Float
    attribute :instrument_name
    attribute :instrument_type, Symbol, allowed_values: Instrument.allowed_values(:type)
    attribute :lot_size, Float
    attribute :low, Float
    attribute :market_status, Symbol, allowed_values: Market::Snapshot.allowed_values(:market_status)
    attribute :net_change, Float
    attribute :offer, Float
    attribute :otc_tradeable, Boolean
    attribute :percentage_change, Float
    attribute :scaling_factor, Float
    attribute :streaming_prices_available, Boolean
    attribute :update_time_utc

    deprecated_attribute :update_time
  end
end
