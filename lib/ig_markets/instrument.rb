module IGMarkets
  class Instrument < Model
    attribute :chart_code
    attribute :contract_size
    attribute :controlled_risk_allowed, type: :boolean
    attribute :country
    attribute :currencies, type: Currency
    attribute :epic
    attribute :expiry
    attribute :expiry_details, type: InstrumentExpiryDetails
    attribute :force_open_allowed, type: :boolean
    attribute :lot_size, type: :float
    attribute :margin_deposit_bands, type: MarginDepositBand
    attribute :margin_factor, type: :float
    attribute :margin_factor_unit
    attribute :market_id
    attribute :name
    attribute :news_code
    attribute :one_pip_means
    attribute :opening_hours, type: OpeningHours
    attribute :rollover_details, type: InstrumentRolloverDetails
    attribute :slippage_factor, type: InstrumentSlippageFactor
    attribute :special_info
    attribute :sprint_markets_maximum_expiry_time, type: :float
    attribute :sprint_markets_minimum_expiry_time, type: :float
    attribute :stops_limits_allowed, type: :boolean
    attribute :streaming_prices_available, type: :boolean
    attribute :type
    attribute :unit
    attribute :value_of_one_pip
  end
end
