FactoryGirl.define do
  factory :activity_details, class: IGMarkets::Activity::Details do
    actions { [build(:activity_details_action)] }
    currency '$'
    direction 'BUY'
    level '0.664'
    limit_level '0.6649'
    market_name 'Spot FX NZD/USD'
    size '+1'
  end
end
