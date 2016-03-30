module IGMarkets
  # An IG Markets Watchlist, see {IGMarkets#watchlists} and {DealingPlatform::WatchlistMethods} for usage details.
  class Watchlist < Model
    attribute :default_system_watchlist, Boolean
    attribute :deleteable, Boolean
    attribute :editable, Boolean
    attribute :id
    attribute :name

    # Returns the markets for this watchlist.
    #
    # @return [Array<Market>]
    def markets
      @dealing_platform.gather "watchlists/#{id}", :markets, Market
    end

    # Deletes this watchlist.
    #
    # @return [void]
    def delete
      @dealing_platform.session.delete "watchlists/#{id}", nil, API_VERSION_1
    end

    # Adds a market to this watchlist.
    #
    # @param [String] epic The EPIC of the market to add to this watchlist.
    #
    # @return [void]
    def add_market(epic)
      @dealing_platform.session.put "watchlists/#{id}", { epic: epic }, API_VERSION_1
    end

    # Removes a market from this watchlist.
    #
    # @param [String] epic The EPIC of the market to remove from this watchlist.
    #
    # @return [void]
    def remove_market(epic)
      @dealing_platform.session.delete "watchlists/#{id}/#{epic}", nil, API_VERSION_1
    end
  end
end
