FactoryGirl.define do
  factory :market, class: IGMarkets::Market do
    dealing_rules { build :market_dealing_rules }
    instrument
    snapshot { build :market_snapshot }
  end
end
