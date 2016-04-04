module IGMarkets
  # Contains details on a market hierarchy query result. Returned by {MarketMethods#hierarchy}.
  class MarketHierarchyResult < Model
    # Contains details on a single node in the market hierarchy. Used by {#nodes}.
    class HierarchyNode < Model
      attribute :id
      attribute :name
    end

    attribute :markets, MarketOverview
    attribute :nodes, HierarchyNode
  end
end
