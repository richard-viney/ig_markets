FactoryGirl.define do
  factory :instrument_expiry_details, class: IGMarkets::Instrument::ExpiryDetails do
    last_dealing_date '2015/01/20 12:13:14'
    settlement_info 'info'
  end
end
