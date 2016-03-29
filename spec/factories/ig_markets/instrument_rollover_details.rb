FactoryGirl.define do
  factory :instrument_rollover_details, class: IGMarkets::Instrument::RolloverDetails do
    last_rollover_time ''
    rollover_info ''
  end
end
