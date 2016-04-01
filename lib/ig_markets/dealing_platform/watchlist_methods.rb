module IGMarkets
  class DealingPlatform
    # Helper class that provides methods for interacting with watchlists.
    class WatchlistMethods
      # Initializes this helper class with the specified dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns all watchlists.
      #
      # @return [Array<Watchlist>]
      def all
        @dealing_platform.gather 'watchlists', :watchlists, Watchlist
      end

      # Creates a new watchlist with a name and an initial set of markets.
      #
      # @return [Watchlist] The new watchlist.
      def create(name, *epics)
        result = @dealing_platform.session.post 'watchlists', { name: name, epics: epics.flatten }, API_VERSION_1

        all.detect { |watchlist| watchlist.id == result.fetch(:watchlist_id) }
      end

      # Returns the watchlist that has the specified ID. Raises ArgumentError if the ID is unrecognized.
      #
      # @param [String] watchlist_id The ID of the watchlist to retrieve.
      #
      # @return [Watchlist]
      def [](watchlist_id)
        watchlist = all.detect { |w| w.id == watchlist_id }

        raise ArgumentError, "Unrecognized watchlist ID: #{watchlist_id}" unless watchlist

        watchlist
      end
    end
  end
end
