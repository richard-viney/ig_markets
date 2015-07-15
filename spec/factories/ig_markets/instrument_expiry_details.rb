FactoryGirl.define do
  factory :instrument_expiry_details, class: IGMarkets::InstrumentExpiryDetails do
    last_dealing_date ''
    settlement_info 'info'
  end
end
