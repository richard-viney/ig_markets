FactoryGirl.define do
  factory :price, class: IGMarkets::Price do
    ask 101.0
    bid 99.0
    last_traded 100.0
  end
end
