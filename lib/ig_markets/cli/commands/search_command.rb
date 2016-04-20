module IGMarkets
  module CLI
    # Implements the `ig_markets search` command.
    class Main < Thor
      desc 'search QUERY', 'Searches markets based on the specified query string'

      def search(query)
        self.class.begin_session(options) do |dealing_platform|
          market_overviews = dealing_platform.markets.search query

          table = MarketOverviewsTable.new market_overviews

          puts table
        end
      end
    end
  end
end
