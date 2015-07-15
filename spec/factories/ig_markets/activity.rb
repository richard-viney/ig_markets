FactoryGirl.define do
  factory :account_activity, class: IGMarkets::AccountActivity do
    action_status 'ACCEPT'
    activity 'description'
    activity_history_id 'id'
    channel 'Mobile'
    currency '$'
    date '20/12/15'
    deal_id 'deal_id'
    epic 'epic'
    level '5253.5'
    limit '5283.5'
    market_name 'FTSE 100'
    period 'DFB'
    result 'result'
    size '+1'
    stop '5233.5'
    stop_type 'N'
    time '07:00'
  end
end
