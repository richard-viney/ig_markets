FactoryGirl.define do
  factory :dealing_rule, class: IGMarkets::Market::DealingRule do
    unit 'POINTS'
    value 1.0
  end
end
