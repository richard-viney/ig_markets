FactoryGirl.define do
  factory :application, class: IGMarkets::Application do
    id 1234
    client_id '8761232322'
    name 'TestAccount'
    tier 'B2C'
    api_key 'api_key'
    status 'ENABLED'
    allowance_application_overall 60.0
    allowance_account_trading 100.0
    allowance_account_overall 30.0
    allowance_account_historical_data 1000.0
    concurrent_subscriptions_limit 40
    created_date 1_433_116_800_000
    allow_equities false
    allow_quote_orders false
    restricted_to_self true
    terms_accepted_date 1_433_116_800_000
    fast_markets_settlement_price_enabled false
  end
end
