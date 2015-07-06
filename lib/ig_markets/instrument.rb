module IGMarkets
  class Instrument
    include ActiveAttr::Model

    attribute :chart_code
    attribute :contract_size
    attribute :controlled_risk_allowed, type: Boolean
    attribute :country
    attribute :currencies, typecaster: proc { |o| o.map { |attributes| Currency.new attributes } }
    attribute :epic
    attribute :expiry
    attribute :expiry_details, typecaster: proc { |attributes| InstrumentExpiryDetails.new attributes }
    attribute :force_open_allowed, type: Boolean
    attribute :lot_size
    attribute :margin_deposit_bands, typecaster: proc { |o| o.map { |attributes| MarginDepositBand.new attributes } }
    attribute :margin_factor, type: Float
    attribute :margin_factor_unit
    attribute :market_id
    attribute :name
    attribute :news_code
    attribute :one_pip_means
    attribute :opening_hours, typecaster: proc { |o| o.map { |attributes| OpeningHours.new attributes } }
    attribute :rollover_details, typecaster: proc { |attributes| InstrumentRolloverDetails.new attributes }
    attribute :slippage_factor, typecaster: proc { |attributes| InstrumentSlippageFactor.new attributes }
    attribute :special_info
    attribute :sprint_markets_maximum_expiry_time, type: Float
    attribute :sprint_markets_minimum_expiry_time, type: Float
    attribute :stops_limits_allowed, type: Boolean
    attribute :streaming_prices_available, type: Boolean
    attribute :type
    attribute :unit
    attribute :value_of_one_pip
  end
end
