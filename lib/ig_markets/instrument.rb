module IGMarkets
  class Instrument < Model
    attribute :chart_code
    attribute :contract_size
    attribute :controlled_risk_allowed, typecaster: AttributeTypecasters.boolean
    attribute :country
    attribute :currencies, typecaster: AttributeTypecasters.currencies
    attribute :epic
    attribute :expiry
    attribute :expiry_details, typecaster: AttributeTypecasters.instrument_expiry_details
    attribute :force_open_allowed, typecaster: AttributeTypecasters.boolean
    attribute :lot_size, typecaster: AttributeTypecasters.float
    attribute :margin_deposit_bands, typecaster: AttributeTypecasters.margin_deposit_bands
    attribute :margin_factor, typecaster: AttributeTypecasters.float
    attribute :margin_factor_unit
    attribute :market_id
    attribute :name
    attribute :news_code
    attribute :one_pip_means
    attribute :opening_hours, typecaster: AttributeTypecasters.opening_hours
    attribute :rollover_details, typecaster: AttributeTypecasters.instrument_rollover_details
    attribute :slippage_factor, typecaster: AttributeTypecasters.instrument_slippage_factor
    attribute :special_info
    attribute :sprint_markets_maximum_expiry_time, typecaster: AttributeTypecasters.float
    attribute :sprint_markets_minimum_expiry_time, typecaster: AttributeTypecasters.float
    attribute :stops_limits_allowed, typecaster: AttributeTypecasters.boolean
    attribute :streaming_prices_available, typecaster: AttributeTypecasters.boolean
    attribute :type
    attribute :unit
    attribute :value_of_one_pip
  end
end
