module IGMarkets
  class Market < Model
    attribute :bid, Float
    attribute :delay_time, Float
    attribute :epic, String, regex: Validate::EPIC_REGEX
    attribute :exchange_id
    attribute :expiry, String, nil_if: '-'
    attribute :high, Float
    attribute :instrument_name
    attribute :instrument_type, Symbol, allowed_values: Instrument.defined_attributes[:type][:allowed_values]
    attribute :lot_size, Float
    attribute :low, Float
    attribute :market_status, Symbol, allowed_values: [
      :closed, :edits_only, :offline, :on_auction, :on_auction_no_edits, :suspended, :tradeable]
    attribute :net_change, Float
    attribute :offer, Float
    attribute :otc_tradeable, Boolean
    attribute :percentage_change, Float
    attribute :scaling_factor, Float
    attribute :streaming_prices_available, Boolean
    attribute :update_time
    attribute :update_time_utc
  end
end
