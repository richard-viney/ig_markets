FactoryGirl.define do
  factory :dealing_rule, class: IGMarkets::DealingRule do
    unit 'POINTS'
    value 1.0
  end
end
