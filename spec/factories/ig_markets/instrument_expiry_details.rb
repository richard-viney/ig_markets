FactoryGirl.define do
  factory :instrument_expiry_details, class: IGMarkets::Instrument::ExpiryDetails do
    last_dealing_date '2022-12-20T23:59'
    settlement_info 'Info'
  end
end
