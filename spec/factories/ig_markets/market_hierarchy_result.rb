FactoryGirl.define do
  factory :market_hierarchy_result, class: IGMarkets::MarketHierarchyResult do
    markets { [build(:market_overview)] }
    nodes { [build(:market_hierarchy_result_hierarchy_node)] }
  end
end
