module IGMarkets
  class Application < Model
    attribute :allow_equities, type: Boolean
    attribute :allow_quote_orders, type: Boolean
    attribute :allowance_account_historical_data, type: Float
    attribute :allowance_account_overall, type: Float
    attribute :allowance_account_trading, type: Float
    attribute :allowance_application_overall, type: Float
    attribute :api_key
    attribute :name
    attribute :status
  end
end
