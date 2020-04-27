FactoryBot.define do
  factory :watchlist, class: 'IGMarkets::Watchlist' do
    id { '2547731' }
    name { 'Markets' }
    editable { false }
    deleteable { false }
    default_system_watchlist { false }
  end
end
