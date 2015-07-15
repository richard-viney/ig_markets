FactoryGirl.define do
  factory :application, class: IGMarkets::Application do
    allow_equities true
    allow_quote_orders true
    allowance_account_historical_data 100.0
    allowance_account_overall 1000.0
    allowance_account_trading 100.0
    allowance_application_overall 1000.0
    api_key 'api_key'
    name 'name'
    status 'ENABLED'
  end
end
