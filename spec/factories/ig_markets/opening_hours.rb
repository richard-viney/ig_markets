FactoryGirl.define do
  factory :opening_hours, class: IGMarkets::OpeningHours do
    close_time '5pm'
    open_time '8am'
  end
end
