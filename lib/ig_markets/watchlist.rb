module IGMarkets
  # Contains details on a watchlist. Returned by {DealingPlatform::WatchlistMethods#all} and
  # {DealingPlatform::WatchlistMethods#[]}.
  class Watchlist < Model
    attribute :default_system_watchlist, Boolean
    attribute :deletable, Boolean
    attribute :editable, Boolean
    attribute :id
    attribute :name

    # Returns the markets for this watchlist.
    #
    # @return [Array<MarketOverview>]
    def markets
      result = @dealing_platform.session.get("watchlists/#{id}").fetch :markets

      @dealing_platform.instantiate_models MarketOverview, result
    end

    # Deletes this watchlist.
    def delete
      @dealing_platform.session.delete "watchlists/#{id}"
    end

    # Adds a market to this watchlist.
    #
    # @param [String] epic The EPIC of the market to add to this watchlist.
    def add_market(epic)
      @dealing_platform.session.put "watchlists/#{id}", epic: epic
    end

    # Removes a market from this watchlist.
    #
    # @param [String] epic The EPIC of the market to remove from this watchlist.
    def remove_market(epic)
      @dealing_platform.session.delete "watchlists/#{id}/#{epic}"
    end
  end
end
