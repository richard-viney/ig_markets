FactoryGirl.define do
  factory :activity_details_action, class: IGMarkets::Activity::Details::Action do
    action_type 'POSITION_CLOSED'
    affected_deal_id 'DIAAAAA4HDKPQEQ'
  end
end
