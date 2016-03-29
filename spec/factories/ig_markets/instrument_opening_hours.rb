FactoryGirl.define do
  factory :instrument_opening_hours, class: IGMarkets::Instrument::OpeningHours do
    close_time '5pm'
    open_time '8am'
  end
end
