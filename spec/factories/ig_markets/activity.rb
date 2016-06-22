FactoryGirl.define do
  factory :activity, class: IGMarkets::Activity do
    channel 'WEB'
    date '2015-12-15T15:00:00'
    deal_id 'DIAAAAA4HDKPQEQ'
    details { build :activity_details }
    epic 'CS.D.NZDUSD.CFD.IP'
    period '-'
    status 'ACCEPTED'
    type 'POSITION'
  end
end

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

FactoryGirl.define do
  factory :activity_details_action, class: IGMarkets::Activity::Details::Action do
    action_type 'POSITION_CLOSED'
    affected_deal_id 'DIAAAAA4HDKPQEQ'
  end
end
