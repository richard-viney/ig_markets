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
