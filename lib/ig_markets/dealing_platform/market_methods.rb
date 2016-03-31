module IGMarkets
  class DealingPlatform
    # Helper class that provides methods for interacting with markets.
    class MarketMethods
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns details on the market hierarchy directly under a single node.
      #
      # @param [String] node_id The ID of the node to return the market hierarchy for. If this is `nil` then details on
      #                         the root node of the market hierarchy will be returned.
      #
      # @return [Hash] A hash containing two keys: `:markets` which is an array of {Market} instances, and `:nodes`
      #                which is an array of {MarketHierarchyNode} instances.
      def hierarchy(node_id = nil)
        url = ['marketnavigation', node_id].compact.join '/'

        result = @dealing_platform.session.get(url, API_VERSION_1)

        {
          markets: MarketOverview.from(result.fetch(:markets) || []),
          nodes: MarketHierarchyNode.from(result.fetch(:nodes) || [])
        }
      end

      # Returns market details for a set of markets.
      #
      # @param [Array<String>] epics The EPICs of the markets to return details for.
      #
      # @return [Array<Market>]
      def find(*epics)
        raise ArgumentError, 'at least one epic must be specified' if epics.empty?

        epics.each do |epic|
          raise ArgumentError, "invalid epic: #{epic}" unless epic.to_s =~ Regex::EPIC
        end

        @dealing_platform.gather "markets?epics=#{epics.join(',')}", :market_details, Market, API_VERSION_2
      end

      # Searches markets based on a query string.
      #
      # @param [String] search_term The search term to use to search the markets.
      #
      # @return [Array<MarketOverview>] An array of the markets that matched the search term.
      def search(search_term)
        @dealing_platform.gather "markets?searchTerm=#{search_term}", :markets, MarketOverview
      end

      # Returns market details for the specified market. Internally a call to {#find} is made.
      #
      # @param [String] epic The EPIC of the market to return details for.
      #
      # @return [Market]
      def [](epic)
        find(epic)[0]
      end
    end
  end
end
