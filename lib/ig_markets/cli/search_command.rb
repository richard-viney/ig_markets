module IGMarkets
  module CLI
    # Implements the `ig_markets search` command.
    class Main < Thor
      desc 'search QUERY', 'Searches markets based on the specified query string'

      def search(query)
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.markets.search(query).each do |market_overview|
            Output.print_market_overview market_overview
          end
        end
      end
    end
  end
end
