module IGMarkets
  class DealingPlatform
    # Provides methods for working with watchlists. Returned by {DealingPlatform#watchlists}.
    class WatchlistMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = WeakRef.new dealing_platform
      end

      # Returns all watchlists.
      #
      # @return [Array<Watchlist>]
      def all
        result = @dealing_platform.session.get('watchlists').fetch :watchlists

        @dealing_platform.instantiate_models Watchlist, result
      end

      # Returns the watchlist that has the specified ID, or `nil` if there is no watchlist with that ID.
      #
      # @param [String] watchlist_id The ID of the watchlist to return.
      #
      # @return [Watchlist]
      def [](watchlist_id)
        all.detect do |watchlist|
          watchlist.id == watchlist_id
        end
      end

      # Creates and returns a new watchlist with a name and an initial set of markets.
      #
      # @return [Watchlist] The new watchlist.
      def create(name, *epics)
        result = @dealing_platform.session.post 'watchlists', name: name, epics: epics.flatten

        self[result.fetch(:watchlist_id)]
      end
    end
  end
end
