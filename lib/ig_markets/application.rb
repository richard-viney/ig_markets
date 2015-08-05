module IGMarkets
  class Application < Model
    attribute :allow_equities, typecaster: AttributeTypecasters.boolean
    attribute :allow_quote_orders, typecaster: AttributeTypecasters.boolean
    attribute :allowance_account_historical_data, typecaster: AttributeTypecasters.float
    attribute :allowance_account_overall, typecaster: AttributeTypecasters.float
    attribute :allowance_account_trading, typecaster: AttributeTypecasters.float
    attribute :allowance_application_overall, typecaster: AttributeTypecasters.float
    attribute :api_key
    attribute :name
    attribute :status
  end
end
