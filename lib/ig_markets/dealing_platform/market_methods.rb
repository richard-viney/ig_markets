module IGMarkets
  class DealingPlatform
    # Provides methods for working with markets. Returned by {DealingPlatform#markets}.
    class MarketMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns details on the market hierarchy directly under the specified node.
      #
      # @param [String] node_id The ID of the node to return the market hierarchy for. If `nil` then details on the root
      #        node of the hierarchy will be returned.
      #
      # @return [MarketHierarchyResult]
      def hierarchy(node_id = nil)
        url = ['marketnavigation', node_id].compact.join '/'

        result = @dealing_platform.session.get url

        @dealing_platform.instantiate_models MarketHierarchyResult, result
      end

      # Returns details for the markets with the passed EPICs.
      #
      # @param [Array<String>] epics The EPICs of the markets to return details for.
      #
      # @return [Array<Market>]
      def find(*epics)
        epics = epics.flatten

        return [] if epics.empty?

        epics.each do |epic|
          raise ArgumentError, "invalid EPIC: #{epic}" unless epic.to_s =~ Regex::EPIC
        end

        # The API imposes a maximum of 50 EPICs per request
        markets = epics.each_slice(50).map do |epics_slice|
          @dealing_platform.session.get("markets?epics=#{epics_slice.join(',')}", API_V2).fetch :market_details
        end

        @dealing_platform.instantiate_models Market, markets.flatten
      end

      # Searches markets using a search term and returns an array of results.
      #
      # @param [String] search_term The search term to use.
      #
      # @return [Array<MarketOverview>]
      def search(search_term)
        result = @dealing_platform.session.get("markets?searchTerm=#{search_term}").fetch :markets

        @dealing_platform.instantiate_models MarketOverview, result
      end

      # Returns market details for the market with the specified EPIC, or `nil` if there is no market with that EPIC.
      # Internally a call to {#find} is made.
      #
      # @param [String] epic The EPIC of the market to return details for.
      #
      # @return [Market]
      def [](epic)
        find(epic).first
      end
    end
  end
end
