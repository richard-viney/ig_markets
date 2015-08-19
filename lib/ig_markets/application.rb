module IGMarkets
  class Application < Model
    attribute :id
    attribute :client_id
    attribute :name
    attribute :tier
    attribute :api_key
    attribute :status
    attribute :allowance_application_overall, type: :float
    attribute :allowance_account_trading, type: :float
    attribute :allowance_account_overall, type: :float
    attribute :allowance_account_historical_data, type: :float
    attribute :concurrent_subscriptions_limit
    attribute :created_date
    attribute :allow_equities, type: :boolean
    attribute :allow_quote_orders, type: :boolean
    attribute :restricted_to_self
    attribute :terms_accepted_date
    attribute :fast_markets_settlement_price_enabled, type: :boolean
  end
end
