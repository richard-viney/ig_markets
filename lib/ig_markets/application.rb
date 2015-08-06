module IGMarkets
  class Application < Model
    attribute :allow_equities, type: :boolean
    attribute :allow_quote_orders, type: :boolean
    attribute :allowance_account_historical_data, type: :float
    attribute :allowance_account_overall, type: :float
    attribute :allowance_account_trading, type: :float
    attribute :allowance_application_overall, type: :float
    attribute :api_key
    attribute :name
    attribute :status
  end
end
