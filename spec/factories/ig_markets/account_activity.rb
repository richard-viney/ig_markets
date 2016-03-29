FactoryGirl.define do
  factory :account_activity, class: IGMarkets::AccountActivity do
    action_status 'ACCEPT'
    activity 'S&L'
    activity_history_id '443487452'
    channel 'Charts'
    currency '$'
    date '20/12/15'
    deal_id 'DIAAAAA4HDKPQEQ'
    epic 'CS.D.NZDUSD.CFD.IP'
    level '0.664'
    limit '0.6649'
    market_name 'Spot FX NZD/USD'
    period '-'
    result 'Result'
    size '+1'
    stop '-'
    stop_type '-'
    time '07:00'
  end
end
