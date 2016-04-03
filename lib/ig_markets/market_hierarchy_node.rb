module IGMarkets
  # Contains details on a single node in the market hierarchy. Returned by {DealingPlatform::MarketMethods#hierarchy}.
  class MarketHierarchyNode < Model
    attribute :id
    attribute :name
  end
end
