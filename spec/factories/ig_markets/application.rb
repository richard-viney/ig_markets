FactoryGirl.define do
  factory :application, class: IGMarkets::Application do
    allow_equities false
    allow_quote_orders false
    allowance_account_historical_data 1000.0
    allowance_account_overall 30.0
    allowance_account_trading 100.0
    allowance_application_overall 60.0
    api_key 'api_key'
    name 'My Account'
    status 'ENABLED'
  end
end
