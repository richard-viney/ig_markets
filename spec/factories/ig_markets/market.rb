FactoryBot.define do
  factory :market, class: 'IGMarkets::Market' do
    dealing_rules { build(:market_dealing_rules) }
    instrument { build(:instrument) }
    snapshot { build(:market_snapshot) }
  end

  factory :market_dealing_rules, class: 'IGMarkets::Market::DealingRules' do
    market_order_preference { 'AVAILABLE_DEFAULT_ON' }
    trailing_stops_preference { 'AVAILABLE' }
    max_stop_or_limit_distance { build(:market_dealing_rules_rule_details) }
    min_controlled_risk_stop_distance { build(:market_dealing_rules_rule_details) }
    min_deal_size { build(:market_dealing_rules_rule_details) }
    min_normal_stop_or_limit_distance { build(:market_dealing_rules_rule_details) }
    min_step_distance { build(:market_dealing_rules_rule_details) }
  end

  factory :market_dealing_rules_rule_details, class: 'IGMarkets::Market::DealingRules::RuleDetails' do
    unit { 'POINTS' }
    value { 1.0 }
  end

  factory :market_snapshot, class: 'IGMarkets::Market::Snapshot' do
    bid { 100.0 }
    binary_odds { 0.5 }
    controlled_risk_extra_spread { 0.01 }
    decimal_places_factor { 1 }
    delay_time { 1 }
    high { 110.0 }
    low { 90.0 }
    market_status { 'TRADEABLE' }
    net_change { 10.0 }
    offer { 99.0 }
    percentage_change { 10 }
    scaling_factor { 100 }
    update_time { '22:10:40' }
  end
end
