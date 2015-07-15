FactoryGirl.define do
  factory :watchlist, class: IGMarkets::Watchlist do
    id '1'
    name 'name'
    editable false
    deleteable false
    default_system_watchlist false
  end
end
