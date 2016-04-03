FactoryGirl.define do
  factory :market_dealing_rules, class: IGMarkets::Market::DealingRules do
    market_order_preference 'AVAILABLE_DEFAULT_ON'
    trailing_stops_preference 'AVAILABLE'
    max_stop_or_limit_distance { build :market_dealing_rules_rule_details }
    min_controlled_risk_stop_distance { build :market_dealing_rules_rule_details }
    min_deal_size { build :market_dealing_rules_rule_details }
    min_normal_stop_or_limit_distance { build :market_dealing_rules_rule_details }
    min_step_distance { build :market_dealing_rules_rule_details }
  end
end
