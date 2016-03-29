module IGMarkets
  class Application < Model
    attribute :allow_equities, Boolean
    attribute :allow_quote_orders, Boolean
    attribute :allowance_account_historical_data, Fixnum
    attribute :allowance_account_overall, Fixnum
    attribute :allowance_account_trading, Fixnum
    attribute :allowance_application_overall, Fixnum
    attribute :api_key
    attribute :client_id
    attribute :concurrent_subscriptions_limit, Fixnum
    attribute :created_date, DateTime, format: '%Q'
    attribute :fast_markets_settlement_price_enabled, Boolean
    attribute :id
    attribute :name
    attribute :restricted_to_self, Boolean
    attribute :status, Symbol, allowed_values: [:disabled, :enabled, :revoked]
    attribute :terms_accepted_date, DateTime, format: '%Q'
    attribute :tier
  end
end
