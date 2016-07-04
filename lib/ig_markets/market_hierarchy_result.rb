module IGMarkets
  # Contains details on a market hierarchy query result. Returned by {DealingPlatform::MarketMethods#hierarchy}.
  class MarketHierarchyResult < Model
    # Contains details on a single node in the market hierarchy. Used by {#nodes}.
    class HierarchyNode < Model
      attribute :id
      attribute :name

      # Returns an array of the markets under this node in the market hierarchy.
      #
      # @return [Array<MarketOverview>]
      def markets
        @dealing_platform.markets.hierarchy(id).markets
      end

      # Returns an array of the child nodes under this node in the market hierarchy.
      #
      # @return [Array<HierarchyNode>]
      def nodes
        @nodes ||= @dealing_platform.markets.hierarchy(id).nodes
      end
    end

    attribute :markets, MarketOverview
    attribute :nodes, HierarchyNode
  end
end
